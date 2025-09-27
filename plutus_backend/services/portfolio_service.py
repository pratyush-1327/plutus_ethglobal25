from typing import List, Dict
import logging
from datetime import datetime

from services.uniswap_service import UniswapService, SubgraphPosition, TokenPrice

logger = logging.getLogger(__name__)

class TokenInfo:
    """Token information model"""
    def __init__(self, address: str, symbol: str, name: str, decimals: int, price_usd: float):
        self.address = address
        self.symbol = symbol
        self.name = name
        self.decimals = decimals
        self.price_usd = price_usd

class Position:
    """LP Position model"""
    def __init__(self, position_id: str, pool_address: str, token0: TokenInfo, token1: TokenInfo,
                 liquidity: str, tick_lower: int, tick_upper: int, value_usd: float,
                 token0_amount: float, token1_amount: float):
        self.position_id = position_id
        self.pool_address = pool_address
        self.token0 = token0
        self.token1 = token1
        self.liquidity = liquidity
        self.tick_lower = tick_lower
        self.tick_upper = tick_upper
        self.value_usd = value_usd
        self.token0_amount = token0_amount
        self.token1_amount = token1_amount

    def to_dict(self):
        return {
            "position_id": self.position_id,
            "pool_address": self.pool_address,
            "token0": {
                "address": self.token0.address,
                "symbol": self.token0.symbol,
                "name": self.token0.name,
                "decimals": self.token0.decimals,
                "price_usd": self.token0.price_usd
            },
            "token1": {
                "address": self.token1.address,
                "symbol": self.token1.symbol,
                "name": self.token1.name,
                "decimals": self.token1.decimals,
                "price_usd": self.token1.price_usd
            },
            "liquidity": self.liquidity,
            "tick_lower": self.tick_lower,
            "tick_upper": self.tick_upper,
            "value_usd": self.value_usd,
            "token0_amount": self.token0_amount,
            "token1_amount": self.token1_amount
        }

class PortfolioService:
    """Service for portfolio calculations and P&L tracking"""

    def __init__(self, uniswap_service: UniswapService):
        self.uniswap_service = uniswap_service

    def get_portfolio_data(self, address: str) -> Dict:
        """
        Get complete portfolio data for a wallet address

        Args:
            address: Ethereum wallet address

        Returns:
            Complete portfolio data with positions and P&L
        """
        try:
            # Fetch user positions from Uniswap subgraph
            raw_positions = self.uniswap_service.get_user_positions(address)

            if not raw_positions:
                return {
                    "address": address,
                    "total_value_usd": 0.0,
                    "pnl_24h_percent": 0.0,
                    "pnl_24h_usd": 0.0,
                    "positions": [],
                    "timestamp": datetime.utcnow().isoformat()
                }

            # Extract unique token addresses
            token_addresses = set()
            for pos in raw_positions:
                token_addresses.add(pos.pool["token0"]["id"])
                token_addresses.add(pos.pool["token1"]["id"])

            # Fetch token prices
            token_prices = self.uniswap_service.get_token_prices(list(token_addresses))

            # Calculate positions and values
            positions = []
            total_value_current = 0.0
            total_value_24h_ago = 0.0

            for raw_pos in raw_positions:
                position = self._calculate_position_value(raw_pos, token_prices)
                positions.append(position)
                total_value_current += position.value_usd

                # Calculate 24h ago value for P&L
                value_24h_ago = self._calculate_position_value_24h_ago(raw_pos, token_prices)
                total_value_24h_ago += value_24h_ago

            # Calculate P&L
            pnl_24h_usd = total_value_current - total_value_24h_ago
            pnl_24h_percent = (pnl_24h_usd / total_value_24h_ago * 100) if total_value_24h_ago > 0 else 0.0

            return {
                "address": address,
                "total_value_usd": total_value_current,
                "pnl_24h_percent": pnl_24h_percent,
                "pnl_24h_usd": pnl_24h_usd,
                "positions": [pos.to_dict() for pos in positions],
                "timestamp": datetime.utcnow().isoformat()
            }

        except Exception as e:
            logger.error(f"Error getting portfolio data for {address}: {e}")
            raise

    def _calculate_position_value(self, raw_position: SubgraphPosition, token_prices: Dict[str, TokenPrice]) -> Position:
        """
        Calculate the current USD value of an LP position

        Args:
            raw_position: Raw position data from subgraph
            token_prices: Token price data

        Returns:
            Position with calculated USD value
        """
        try:
            pool = raw_position.pool
            token0_address = pool["token0"]["id"]
            token1_address = pool["token1"]["id"]

            # Get current tick from pool
            current_tick = int(pool["tick"])

            # Calculate token amounts (simplified for demo)
            liquidity_value = float(raw_position.liquidity) if raw_position.liquidity else 0.0

            # Adjust for token decimals
            token0_decimals = int(pool["token0"]["decimals"])
            token1_decimals = int(pool["token1"]["decimals"])

            # Simplified calculation - in production, use proper Uniswap V3 math
            token0_amount_adjusted = liquidity_value / (10 ** token0_decimals) * 0.5
            token1_amount_adjusted = liquidity_value / (10 ** token1_decimals) * 0.5

            # Get token prices
            token0_price = token_prices.get(token0_address)
            token1_price = token_prices.get(token1_address)

            # Calculate USD values
            token0_value_usd = token0_amount_adjusted * (token0_price.price_usd if token0_price else 0.0)
            token1_value_usd = token1_amount_adjusted * (token1_price.price_usd if token1_price else 0.0)
            total_value_usd = token0_value_usd + token1_value_usd

            # Create TokenInfo objects
            token0_info = TokenInfo(
                address=token0_address,
                symbol=pool["token0"]["symbol"],
                name=pool["token0"]["name"],
                decimals=token0_decimals,
                price_usd=token0_price.price_usd if token0_price else 0.0
            )

            token1_info = TokenInfo(
                address=token1_address,
                symbol=pool["token1"]["symbol"],
                name=pool["token1"]["name"],
                decimals=token1_decimals,
                price_usd=token1_price.price_usd if token1_price else 0.0
            )

            return Position(
                position_id=raw_position.id,
                pool_address=pool["id"],
                token0=token0_info,
                token1=token1_info,
                liquidity=raw_position.liquidity,
                tick_lower=int(raw_position.tickLower["tickIdx"]),
                tick_upper=int(raw_position.tickUpper["tickIdx"]),
                value_usd=total_value_usd,
                token0_amount=token0_amount_adjusted,
                token1_amount=token1_amount_adjusted
            )

        except Exception as e:
            logger.error(f"Error calculating position value: {e}")
            raise

    def _calculate_position_value_24h_ago(self, raw_position: SubgraphPosition, token_prices: Dict[str, TokenPrice]) -> float:
        """
        Calculate the USD value of a position 24 hours ago for P&L calculation

        Args:
            raw_position: Raw position data
            token_prices: Token price data with historical prices

        Returns:
            Position value 24 hours ago in USD
        """
        try:
            pool = raw_position.pool
            token0_address = pool["token0"]["id"]
            token1_address = pool["token1"]["id"]

            # Simplified calculation - same amounts as current
            liquidity_value = float(raw_position.liquidity) if raw_position.liquidity else 0.0
            token0_decimals = int(pool["token0"]["decimals"])
            token1_decimals = int(pool["token1"]["decimals"])

            token0_amount_adjusted = liquidity_value / (10 ** token0_decimals) * 0.5
            token1_amount_adjusted = liquidity_value / (10 ** token1_decimals) * 0.5

            # Get 24h ago prices
            token0_price = token_prices.get(token0_address)
            token1_price = token_prices.get(token1_address)

            token0_price_24h = token0_price.price_24h_ago if token0_price and token0_price.price_24h_ago else (token0_price.price_usd if token0_price else 0.0)
            token1_price_24h = token1_price.price_24h_ago if token1_price and token1_price.price_24h_ago else (token1_price.price_usd if token1_price else 0.0)

            # Calculate USD values 24h ago
            token0_value_usd_24h = token0_amount_adjusted * token0_price_24h
            token1_value_usd_24h = token1_amount_adjusted * token1_price_24h

            return token0_value_usd_24h + token1_value_usd_24h

        except Exception as e:
            logger.error(f"Error calculating 24h ago value: {e}")
            return 0.0

    def calculate_lp_value(self, position_id: str, token0_price: float, token1_price: float) -> float:
        """
        Calculate LP position value (as requested in the spec)

        Args:
            position_id: Position identifier
            token0_price: Current price of token0
            token1_price: Current price of token1

        Returns:
            Current USD value of the position
        """
        logger.info(f"Calculating LP value for position {position_id}")

        # This would typically involve:
        # 1. Fetch position data by ID
        # 2. Calculate token amounts based on current pool state
        # 3. Multiply by provided prices
        # 4. Return total USD value

        # Placeholder implementation
        return 0.0