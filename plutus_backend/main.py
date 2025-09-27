from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import logging
from datetime import datetime, timedelta
from dotenv import load_dotenv
from typing import Dict, Any, List, Optional
import random

from services.uniswap_service import UniswapService
from services.portfolio_service import PortfolioService

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Plutus DeFi Backend",
    description="Backend service for Plutus DeFi Portfolio Tracker",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Add CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize services
uniswap_service = UniswapService()
portfolio_service = PortfolioService(uniswap_service)

# Pydantic models for requests
class SwapRequest(BaseModel):
    wallet_address: str
    token_in: str
    token_out: str
    amount_in: str
    slippage: float = 0.5
    chain_id: int = 1

class AddLiquidityRequest(BaseModel):
    wallet_address: str
    token0: str
    token1: str
    amount0: str
    amount1: str
    fee: int = 3000
    tick_lower: int
    tick_upper: int
    chain_id: int = 1

class NetworkSwitchRequest(BaseModel):
    chain_id: int

@app.get("/")
async def root():
    """Health check endpoint"""
    return {"message": "Plutus DeFi Backend is running", "version": "2.0.0"}

@app.get("/portfolio/{address}")
async def get_portfolio(address: str, chain_id: int = 1) -> Dict[str, Any]:
    """
    Get complete portfolio data for a wallet address on specific chain

    Args:
        address: Ethereum wallet address
        chain_id: Blockchain network ID (1=Ethereum, 137=Polygon, 10=Optimism)

    Returns:
        JSON response with portfolio data including positions, values, and P&L
    """
    try:
        # Validate address format
        if not address.startswith("0x") or len(address) != 42:
            raise HTTPException(status_code=400, detail="Invalid Ethereum address format")

        # Get portfolio data with chain support
        portfolio_data = portfolio_service.get_portfolio_data(address, chain_id)
        portfolio_data["chain_id"] = chain_id
        portfolio_data["chain_name"] = _get_chain_name(chain_id)

        return portfolio_data

    except Exception as e:
        logger.error(f"Error fetching portfolio data: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error fetching portfolio data: {str(e)}")

@app.get("/analytics/{address}")
async def get_analytics(address: str, timeframe: str = "7d", chain_id: int = 1) -> Dict[str, Any]:
    """
    Get analytics data for portfolio including historical performance

    Args:
        address: Ethereum wallet address
        timeframe: Time range for analytics (24h, 7d, 30d, 1y)
        chain_id: Blockchain network ID
    """
    try:
        if not address.startswith("0x") or len(address) != 42:
            raise HTTPException(status_code=400, detail="Invalid Ethereum address format")

        # Generate analytics data (using mock data for now, but structured for real API)
        analytics_data = _generate_analytics_data(address, timeframe, chain_id)

        return analytics_data

    except Exception as e:
        logger.error(f"Error fetching analytics data: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error fetching analytics data: {str(e)}")

@app.get("/performance/{address}")
async def get_performance(address: str, chain_id: int = 1) -> Dict[str, Any]:
    """
    Get performance metrics and historical data
    """
    try:
        # Get current portfolio
        portfolio = portfolio_service.get_portfolio_data(address, chain_id)

        # Generate performance data
        performance_data = {
            "current_value": portfolio.get("total_value_usd", 0),
            "total_pnl": portfolio.get("pnl_24h_usd", 0) * 30,  # Estimate monthly
            "total_pnl_percent": portfolio.get("pnl_24h_percent", 0) * 30,
            "fees_earned": sum([pos.get("fees_earned", 0) for pos in portfolio.get("positions", [])]),
            "impermanent_loss": sum([pos.get("impermanent_loss", 0) for pos in portfolio.get("positions", [])]),
            "historical_data": _generate_historical_data(address, 30),  # 30 days
            "chain_id": chain_id
        }

        return performance_data

    except Exception as e:
        logger.error(f"Error fetching performance data: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error fetching performance data: {str(e)}")

@app.post("/swap/simulate")
async def simulate_swap(request: SwapRequest) -> Dict[str, Any]:
    """
    Simulate a token swap transaction
    """
    try:
        # Mock swap simulation (replace with real DEX API integration)
        simulation_result = {
            "success": True,
            "estimated_output": float(request.amount_in) * 0.998,  # Mock 0.2% slippage
            "minimum_output": float(request.amount_in) * (1 - request.slippage / 100),
            "gas_estimate": random.randint(150000, 300000),
            "gas_price": "20",  # gwei
            "price_impact": round(random.uniform(0.1, 2.0), 2),
            "route": [request.token_in, request.token_out],
            "chain_id": request.chain_id
        }

        return simulation_result

    except Exception as e:
        logger.error(f"Error simulating swap: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error simulating swap: {str(e)}")

@app.post("/liquidity/add/simulate")
async def simulate_add_liquidity(request: AddLiquidityRequest) -> Dict[str, Any]:
    """
    Simulate adding liquidity to Uniswap V3
    """
    try:
        # Mock liquidity simulation
        simulation_result = {
            "success": True,
            "estimated_liquidity": random.randint(1000000, 10000000),
            "token0_amount": request.amount0,
            "token1_amount": request.amount1,
            "estimated_fees_apy": round(random.uniform(5.0, 25.0), 2),
            "gas_estimate": random.randint(250000, 500000),
            "gas_price": "20",
            "tick_lower": request.tick_lower,
            "tick_upper": request.tick_upper,
            "chain_id": request.chain_id
        }

        return simulation_result

    except Exception as e:
        logger.error(f"Error simulating add liquidity: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error simulating add liquidity: {str(e)}")

@app.get("/tokens/popular/{chain_id}")
async def get_popular_tokens(chain_id: int = 1) -> Dict[str, Any]:
    """
    Get popular tokens for a specific chain
    """
    try:
        popular_tokens = _get_popular_tokens_for_chain(chain_id)
        return {
            "chain_id": chain_id,
            "chain_name": _get_chain_name(chain_id),
            "tokens": popular_tokens
        }

    except Exception as e:
        logger.error(f"Error fetching popular tokens: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error fetching popular tokens: {str(e)}")

@app.get("/networks")
async def get_supported_networks() -> Dict[str, Any]:
    """
    Get all supported networks
    """
    networks = {
        "1": {
            "name": "Ethereum",
            "symbol": "ETH",
            "explorer": "https://etherscan.io",
            "rpc": "https://mainnet.infura.io/v3/YOUR_KEY",
            "active": True
        },
        "137": {
            "name": "Polygon",
            "symbol": "MATIC",
            "explorer": "https://polygonscan.com",
            "rpc": "https://polygon-rpc.com",
            "active": True
        },
        "10": {
            "name": "Optimism",
            "symbol": "ETH",
            "explorer": "https://optimistic.etherscan.io",
            "rpc": "https://mainnet.optimism.io",
            "active": True
        }
    }

    return {"networks": networks}

@app.post("/positions/{position_id}/claim")
async def claim_fees(position_id: str, wallet_address: str) -> Dict[str, Any]:
    """
    Simulate claiming fees from a Uniswap V3 position
    """
    try:
        # Mock fee claiming
        claim_result = {
            "success": True,
            "transaction_hash": f"0x{''.join(random.choices('0123456789abcdef', k=64))}",
            "fees_claimed": {
                "token0": round(random.uniform(0.1, 5.0), 4),
                "token1": round(random.uniform(0.1, 5.0), 4),
                "usd_value": round(random.uniform(10, 500), 2)
            },
            "gas_used": random.randint(80000, 150000),
            "gas_price": "20"
        }

        return claim_result

    except Exception as e:
        logger.error(f"Error claiming fees: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error claiming fees: {str(e)}")

def _get_chain_name(chain_id: int) -> str:
    """Get chain name from chain ID"""
    chains = {
        1: "Ethereum",
        137: "Polygon",
        10: "Optimism"
    }
    return chains.get(chain_id, "Unknown")

def _generate_analytics_data(address: str, timeframe: str, chain_id: int) -> Dict[str, Any]:
    """Generate analytics data for the given timeframe"""
    # Convert timeframe to days
    days_map = {"24h": 1, "7d": 7, "30d": 30, "1y": 365}
    days = days_map.get(timeframe, 7)

    # Generate historical chart data
    chart_data = []
    base_value = 50000 if address in ["0xe592427a0aece92de3edee1f18e0157c05861564"] else 2000

    for i in range(days):
        date = datetime.now() - timedelta(days=days-i)
        value = base_value * (1 + random.uniform(-0.05, 0.08))  # +/- 5-8% daily variation
        chart_data.append({
            "date": date.strftime("%Y-%m-%d"),
            "value": round(value, 2)
        })

    return {
        "address": address,
        "timeframe": timeframe,
        "chain_id": chain_id,
        "chart_data": chart_data,
        "total_return": round(random.uniform(5, 45), 2),
        "total_return_percent": round(random.uniform(10, 85), 2),
        "fees_earned": round(random.uniform(100, 5000), 2),
        "impermanent_loss": round(random.uniform(-500, 0), 2),
        "best_performing_position": "ETH/USDC 0.3%",
        "worst_performing_position": "UNI/ETH 1%"
    }

def _generate_historical_data(address: str, days: int) -> List[Dict[str, Any]]:
    """Generate historical portfolio value data"""
    data = []
    base_value = 50000 if address in ["0xe592427a0aece92de3edee1f18e0157c05861564"] else 2000

    for i in range(days):
        date = datetime.now() - timedelta(days=days-i)
        value = base_value * (1 + random.uniform(-0.03, 0.05))
        data.append({
            "date": date.strftime("%Y-%m-%d"),
            "value": round(value, 2),
            "pnl": round(random.uniform(-100, 200), 2),
            "pnl_percent": round(random.uniform(-2, 4), 2)
        })

    return data

def _get_popular_tokens_for_chain(chain_id: int) -> List[Dict[str, Any]]:
    """Get popular tokens for a specific blockchain"""
    if chain_id == 1:  # Ethereum
        return [
            {"symbol": "ETH", "address": "0x0000000000000000000000000000000000000000", "name": "Ethereum", "price": 2500.00},
            {"symbol": "USDC", "address": "0xa0b86a33e6d3c7e6b6ed2df4fe3c396d8b7b8dc2", "name": "USD Coin", "price": 1.00},
            {"symbol": "UNI", "address": "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984", "name": "Uniswap", "price": 25.00},
            {"symbol": "WBTC", "address": "0x2260fac5e5542a773aa44fbcfedf7c193bc2c599", "name": "Wrapped Bitcoin", "price": 65000.00}
        ]
    elif chain_id == 137:  # Polygon
        return [
            {"symbol": "MATIC", "address": "0x0000000000000000000000000000000000001010", "name": "Polygon", "price": 0.85},
            {"symbol": "USDC", "address": "0x2791bca1f2de4661ed88a30c99a7a9449aa84174", "name": "USD Coin", "price": 1.00},
            {"symbol": "WETH", "address": "0x7ceb23fd6f0c9c7b53ff7f00a0fcdb6b73e837e7", "name": "Wrapped Ether", "price": 2500.00}
        ]
    elif chain_id == 10:  # Optimism
        return [
            {"symbol": "ETH", "address": "0x0000000000000000000000000000000000000000", "name": "Ethereum", "price": 2500.00},
            {"symbol": "USDC", "address": "0x7f5c764cbc14f9669b88837ca1490cca17c31607", "name": "USD Coin", "price": 1.00},
            {"symbol": "OP", "address": "0x4200000000000000000000000000000000000042", "name": "Optimism", "price": 2.50}
        ]
    else:
        return []

@app.get("/health")
async def health_check():
    """Health check for the service"""
    return {
        "status": "healthy",
        "service": "uniswap-backend",
        "version": "1.0.0",
        "timestamp": datetime.utcnow().isoformat()
    }

if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", 8000))
    debug = os.getenv("DEBUG", "False").lower() == "true"
    uvicorn.run(app, host="0.0.0.0", port=port, reload=debug)