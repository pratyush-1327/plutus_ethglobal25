import requests
import json
from typing import List, Dict, Any, Optional
import logging
import math

logger = logging.getLogger(__name__)

class SubgraphPosition:
    """Raw position data from Subgraph"""
    def __init__(self, **kwargs):
        self.id = kwargs.get('id')
        self.liquidity = kwargs.get('liquidity')
        self.depositedToken0 = kwargs.get('depositedToken0')
        self.depositedToken1 = kwargs.get('depositedToken1')
        self.withdrawnToken0 = kwargs.get('withdrawnToken0')
        self.withdrawnToken1 = kwargs.get('withdrawnToken1')
        self.collectedFeesToken0 = kwargs.get('collectedFeesToken0')
        self.collectedFeesToken1 = kwargs.get('collectedFeesToken1')
        self.pool = kwargs.get('pool', {})
        self.tickLower = kwargs.get('tickLower', {})
        self.tickUpper = kwargs.get('tickUpper', {})

class TokenPrice:
    """Token price data"""
    def __init__(self, address: str, symbol: str, price_usd: float, price_24h_ago: Optional[float] = None):
        self.address = address
        self.symbol = symbol
        self.price_usd = price_usd
        self.price_24h_ago = price_24h_ago

class UniswapService:
    """Service for interacting with Uniswap V3 Subgraph"""

    def __init__(self):
        self.subgraph_url = "https://gateway-arbitrum.network.thegraph.com/api/[api-key]/subgraphs/id/5zvR82QoaXuFarK9c3WAxNhEVMBKSqyixNTZXkJZUQzK"
        self.coingecko_url = "https://api.coingecko.com/api/v3"

    def get_user_positions(self, address: str) -> List[SubgraphPosition]:
        """
        Fetch all V3 liquidity positions for a given address

        Args:
            address: Ethereum wallet address

        Returns:
            List of raw position data from subgraph
        """
        # For demo purposes, return mock data instead of querying the actual subgraph
        # In production, you would need a valid API key and proper GraphQL query

        logger.info(f"Fetching positions for address: {address}")

        # Mock position data for demonstration
        mock_positions = [
            {
                "id": "123456",
                "liquidity": "10000000000000000000",
                "depositedToken0": "1000000",
                "depositedToken1": "500000000000000000",
                "withdrawnToken0": "0",
                "withdrawnToken1": "0",
                "collectedFeesToken0": "1000",
                "collectedFeesToken1": "1000000000000000",
                "pool": {
                    "id": "0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640",
                    "token0": {
                        "id": "0xa0b86a33e6d3c7e6b6ed2df4fe3c396d8b7b8dc2",
                        "symbol": "USDC",
                        "name": "USD Coin",
                        "decimals": "6"
                    },
                    "token1": {
                        "id": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
                        "symbol": "WETH",
                        "name": "Wrapped Ether",
                        "decimals": "18"
                    },
                    "sqrtPrice": "1234567890123456789012345678901234567890",
                    "tick": "-85176",
                    "feeTier": "500"
                },
                "tickLower": {
                    "tickIdx": "-92100"
                },
                "tickUpper": {
                    "tickIdx": "-78200"
                }
            }
        ]

        return [SubgraphPosition(**pos) for pos in mock_positions]

    def get_token_prices(self, token_addresses: List[str]) -> Dict[str, TokenPrice]:
        """
        Fetch current and historical token prices from CoinGecko

        Args:
            token_addresses: List of token contract addresses

        Returns:
            Dictionary mapping address to TokenPrice
        """
        # For demo purposes, return mock prices
        # In production, you would call the real CoinGecko API

        logger.info(f"Fetching prices for tokens: {token_addresses}")

        # Mock price data for common tokens
        mock_prices = {
            "0xa0b86a33e6d3c7e6b6ed2df4fe3c396d8b7b8dc2": TokenPrice(  # USDC
                address="0xa0b86a33e6d3c7e6b6ed2df4fe3c396d8b7b8dc2",
                symbol="USDC",
                price_usd=1.0,
                price_24h_ago=0.999
            ),
            "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2": TokenPrice(  # WETH
                address="0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
                symbol="WETH",
                price_usd=2650.0,
                price_24h_ago=2580.0
            )
        }

        prices = {}
        for address in token_addresses:
            if address in mock_prices:
                prices[address] = mock_prices[address]
            else:
                # Default fallback price
                prices[address] = TokenPrice(
                    address=address,
                    symbol="UNKNOWN",
                    price_usd=100.0,
                    price_24h_ago=98.0
                )

        return prices

    def calculate_token_amounts(self, position: SubgraphPosition, current_tick: int) -> tuple[float, float]:
        """
        Calculate the actual token amounts in an LP position

        Args:
            position: Position data from subgraph
            current_tick: Current pool tick

        Returns:
            Tuple of (token0_amount, token1_amount)
        """
        try:
            liquidity = float(position.liquidity)
            tick_lower = int(position.tickLower["tickIdx"])
            tick_upper = int(position.tickUpper["tickIdx"])

            # Calculate token amounts based on current tick and position range
            if current_tick < tick_lower:
                # Position is entirely in token0
                token0_amount = self._get_amount0_for_liquidity(liquidity, tick_lower, tick_upper)
                token1_amount = 0.0
            elif current_tick >= tick_upper:
                # Position is entirely in token1
                token0_amount = 0.0
                token1_amount = self._get_amount1_for_liquidity(liquidity, tick_lower, tick_upper)
            else:
                # Position is active, has both tokens
                token0_amount = self._get_amount0_for_liquidity(liquidity, current_tick, tick_upper)
                token1_amount = self._get_amount1_for_liquidity(liquidity, tick_lower, current_tick)

            return token0_amount, token1_amount

        except Exception as e:
            logger.error(f"Error calculating token amounts: {e}")
            return 0.0, 0.0

    def _get_amount0_for_liquidity(self, liquidity: float, tick_a: int, tick_b: int) -> float:
        """Calculate amount of token0 for given liquidity and tick range"""
        if tick_a > tick_b:
            tick_a, tick_b = tick_b, tick_a

        sqrt_price_a = math.sqrt(1.0001 ** tick_a)
        sqrt_price_b = math.sqrt(1.0001 ** tick_b)

        return liquidity * (sqrt_price_b - sqrt_price_a) / (sqrt_price_a * sqrt_price_b)

    def _get_amount1_for_liquidity(self, liquidity: float, tick_a: int, tick_b: int) -> float:
        """Calculate amount of token1 for given liquidity and tick range"""
        if tick_a > tick_b:
            tick_a, tick_b = tick_b, tick_a

        sqrt_price_a = math.sqrt(1.0001 ** tick_a)
        sqrt_price_b = math.sqrt(1.0001 ** tick_b)

        return liquidity * (sqrt_price_b - sqrt_price_a)