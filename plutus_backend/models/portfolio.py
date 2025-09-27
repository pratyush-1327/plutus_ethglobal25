from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime

class TokenInfo(BaseModel):
    """Token information model"""
    address: str
    symbol: str
    name: str
    decimals: int
    price_usd: float = Field(..., description="Current price in USD")

class Position(BaseModel):
    """LP Position model"""
    position_id: str = Field(..., description="Unique position identifier")
    pool_address: str = Field(..., description="Pool contract address")
    token0: TokenInfo
    token1: TokenInfo
    liquidity: str = Field(..., description="Liquidity amount")
    tick_lower: int = Field(..., description="Lower tick boundary")
    tick_upper: int = Field(..., description="Upper tick boundary")
    value_usd: float = Field(..., description="Current USD value")
    token0_amount: float = Field(..., description="Amount of token0")
    token1_amount: float = Field(..., description="Amount of token1")

class PortfolioResponse(BaseModel):
    """Portfolio response model"""
    address: str = Field(..., description="Wallet address")
    total_value_usd: float = Field(..., description="Total portfolio value in USD")
    pnl_24h_percent: float = Field(..., description="24-hour P&L percentage")
    pnl_24h_usd: float = Field(..., description="24-hour P&L in USD")
    positions: List[Position] = Field(default_factory=list, description="List of LP positions")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="Response timestamp")

class SubgraphPosition(BaseModel):
    """Raw position data from Subgraph"""
    id: str
    liquidity: str
    depositedToken0: str
    depositedToken1: str
    withdrawnToken0: str
    withdrawnToken1: str
    collectedFeesToken0: str
    collectedFeesToken1: str
    pool: Dict[str, Any]
    tickLower: Dict[str, Any]
    tickUpper: Dict[str, Any]

class TokenPrice(BaseModel):
    """Token price data"""
    address: str
    symbol: str
    price_usd: float
    price_24h_ago: Optional[float] = None