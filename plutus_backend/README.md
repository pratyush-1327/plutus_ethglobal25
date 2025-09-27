# Uniswap Flutter Backend

A Python backend service that integrates with Uniswap V3 to provide portfolio data for Flutter mobile applications. This backend fetches LP positions, calculates current values, and tracks 24-hour P&L performance.

## Features

- **Uniswap V3 Integration**: Mock data integration ready for Subgraph queries
- **LP Position Tracking**: Fetch and calculate liquidity position values
- **24-Hour P&L Calculation**: Track portfolio performance over time
- **RESTful API**: Simple Flask endpoints for mobile app integration
- **Real-time Data**: Current token prices and position values

## Tech Stack

- **Flask 3.0**: Python web framework
- **Requests**: HTTP client for external API calls
- **Python 3.13**: Modern Python runtime

## API Endpoints

### Health Check
```
GET /
```
Returns service status

### Get Portfolio Data
```
GET /portfolio/{address}
```

Returns complete portfolio data including:
- All V3 liquidity positions
- Current position values in USD
- 24-hour P&L percentage and USD amount
- Token holdings breakdown

**Example Response:**
```json
{
  "address": "0x742d35cC6632C0532C3E7C6E66B1fDA2bD3c6f7C",
  "total_value_usd": 5000000013250.0,
  "pnl_24h_percent": 0.10,
  "pnl_24h_usd": 5000000350.0,
  "positions": [
    {
      "position_id": "123456",
      "pool_address": "0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640",
      "token0": {
        "address": "0xa0b86a33e6d3c7e6b6ed2df4fe3c396d8b7b8dc2",
        "symbol": "USDC",
        "name": "USD Coin",
        "decimals": 6,
        "price_usd": 1.0
      },
      "token1": {
        "address": "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2",
        "symbol": "WETH",
        "name": "Wrapped Ether",
        "decimals": 18,
        "price_usd": 2650.0
      },
      "liquidity": "10000000000000000000",
      "tick_lower": -92100,
      "tick_upper": -78200,
      "value_usd": 5000000013250.0,
      "token0_amount": 5000000000000.0,
      "token1_amount": 5.0
    }
  ],
  "timestamp": "2025-09-26T13:32:28.023216"
}
```

### Health Check
```
GET /health
```
Detailed service health information

## Installation

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Run the server:
```bash
python main.py
```

3. Access the API at `http://localhost:8000`

## Development

### VS Code Tasks
The project includes a VS Code task for running the server:
- **Start Flask Server**: Runs `python main.py` in the background

### Testing Endpoints
```bash
# Test health check
curl http://localhost:8000/

# Test portfolio endpoint
curl http://localhost:8000/portfolio/0x742d35cC6632C0532C3E7C6E66B1fDA2bD3c6f7C
```

## Environment Variables

- `PORT`: Server port (default: 8000)
- `DEBUG`: Enable debug mode (default: False)

## Production Considerations

### For Production Use:
1. **Real Subgraph Integration**: Replace mock data with actual Uniswap V3 Subgraph queries
2. **API Keys**: Add TheGraph API key for subgraph access
3. **Real Price Data**: Integrate with CoinGecko or other price APIs
4. **Error Handling**: Enhanced error handling and logging
5. **Security**: Add authentication and rate limiting
6. **WSGI Server**: Use Gunicorn or uWSGI instead of Flask dev server

### Required Updates:
```python
# Update in services/uniswap_service.py
self.subgraph_url = "https://gateway-arbitrum.network.thegraph.com/api/[YOUR_API_KEY]/subgraphs/id/..."

# Enable real GraphQL queries instead of mock data
# Enable real CoinGecko API calls for prices
```

## Architecture

### Services
- **UniswapService**: Handles Subgraph queries and price data
- **PortfolioService**: Calculates position values and P&L

### Models
- **Position**: LP position with value calculations
- **TokenInfo**: Token metadata and pricing
- **SubgraphPosition**: Raw position data from Subgraph

### Key Functions
- `get_user_positions(address)`: Fetch user's LP positions
- `get_token_prices(addresses)`: Get current and historical prices
- `calculate_lp_value(position, prices)`: Calculate USD value of positions
- `get_portfolio_data(address)`: Complete portfolio with P&L calculations

## Flutter Integration

Your Flutter app can call the `/portfolio/{address}` endpoint to get complete portfolio data in JSON format. The response includes all necessary data for displaying:

- Total portfolio value
- Individual position details
- 24-hour performance metrics
- Token information with current prices

## License

This project is provided as a development template. Update with your preferred license for production use.