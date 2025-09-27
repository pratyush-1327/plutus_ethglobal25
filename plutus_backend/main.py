from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import logging
from datetime import datetime
from dotenv import load_dotenv
from typing import Dict, Any

from services.uniswap_service import UniswapService
from services.portfolio_service import PortfolioService

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Uniswap Flutter Backend",
    description="Backend service for Flutter app with Uniswap V3 integration",
    version="1.0.0",
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

@app.get("/")
async def root():
    """Health check endpoint"""
    return {"message": "Uniswap Flutter Backend is running"}

@app.get("/portfolio/{address}")
async def get_portfolio(address: str) -> Dict[str, Any]:
    """
    Get complete portfolio data for a wallet address

    Args:
        address: Ethereum wallet address

    Returns:
        JSON response with portfolio data including positions, values, and P&L
    """
    try:
        # Validate address format (basic validation)
        if not address.startswith("0x") or len(address) != 42:
            raise HTTPException(status_code=400, detail="Invalid Ethereum address format")

        # Get portfolio data
        portfolio_data = portfolio_service.get_portfolio_data(address)

        return portfolio_data

    except Exception as e:
        logger.error(f"Error fetching portfolio data: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error fetching portfolio data: {str(e)}")

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