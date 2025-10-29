#!/bin/bash
# Render Deployment Verification Script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - Update these with your actual URLs
BACKEND_URL="https://your-backend-service.onrender.com"
FRONTEND_URL="https://your-frontend-service.onrender.com"

echo -e "${BLUE}🚀 Personal Expense Tracker - Render Deployment Verification${NC}"
echo "=================================================="

# Function to check URL
check_url() {
    local url=$1
    local description=$2
    
    echo -n "Checking $description... "
    
    if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "200\|301\|302"; then
        echo -e "${GREEN}✅ SUCCESS${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        return 1
    fi
}

# Function to test API endpoint
test_api_endpoint() {
    local endpoint=$1
    local description=$2
    local expected_pattern=$3
    
    echo -n "Testing $description... "
    
    response=$(curl -s "$BACKEND_URL$endpoint")
    
    if [[ $response == *"$expected_pattern"* ]]; then
        echo -e "${GREEN}✅ SUCCESS${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        echo -e "${YELLOW}Response: $response${NC}"
        return 1
    fi
}

# Function to create test expense
create_test_expense() {
    echo -n "Creating test expense... "
    
    response=$(curl -s -X POST "$BACKEND_URL/api/expenses" \
        -H "Content-Type: application/json" \
        -d '{
            "title": "Render Deployment Test",
            "amount": 99.99,
            "categoryId": 1,
            "date": "2025-10-29",
            "description": "Test expense created during deployment verification"
        }')
    
    if [[ $response == *"title"* ]] && [[ $response == *"Render Deployment Test"* ]]; then
        echo -e "${GREEN}✅ SUCCESS${NC}"
        echo -e "${YELLOW}Created: $response${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED${NC}"
        echo -e "${YELLOW}Response: $response${NC}"
        return 1
    fi
}

echo -e "\n${BLUE}1. Basic Connectivity Tests${NC}"
echo "----------------------------"

# Test backend health
check_url "$BACKEND_URL" "Backend service"

# Test frontend
check_url "$FRONTEND_URL" "Frontend service"

echo -e "\n${BLUE}2. API Endpoint Tests${NC}"
echo "---------------------"

# Test categories endpoint
test_api_endpoint "/api/categories" "Categories API" "name"

# Test expenses endpoint
test_api_endpoint "/api/expenses" "Expenses API" "[]"

echo -e "\n${BLUE}3. Functional Tests${NC}"
echo "-------------------"

# Create a test expense
create_test_expense

# Verify the expense was created
echo -n "Verifying test expense exists... "
expenses_response=$(curl -s "$BACKEND_URL/api/expenses")
if [[ $expenses_response == *"Render Deployment Test"* ]]; then
    echo -e "${GREEN}✅ SUCCESS${NC}"
else
    echo -e "${RED}❌ FAILED${NC}"
    echo -e "${YELLOW}Expenses response: $expenses_response${NC}"
fi

echo -e "\n${BLUE}4. Integration Test${NC}"
echo "-------------------"

echo "Manual verification steps:"
echo "1. Open frontend: $FRONTEND_URL"
echo "2. Add a new expense through the UI"
echo "3. Verify it appears in the expense list"
echo "4. Check backend logs in Render dashboard"

echo -e "\n${BLUE}5. Performance Check${NC}"
echo "--------------------"

# Response time check
echo -n "Backend response time... "
response_time=$(curl -o /dev/null -s -w "%{time_total}" "$BACKEND_URL/api/categories")
echo -e "${YELLOW}${response_time}s${NC}"

if (( $(echo "$response_time < 5.0" | bc -l) )); then
    echo -e "${GREEN}✅ Response time acceptable${NC}"
else
    echo -e "${YELLOW}⚠️  Slow response time${NC}"
fi

echo -e "\n${BLUE}Deployment Verification Complete!${NC}"
echo "=================================="

echo -e "\n${GREEN}🎉 Your Personal Expense Tracker is deployed and functional!${NC}"
echo ""
echo "URLs:"
echo "- Backend API: $BACKEND_URL"
echo "- Frontend App: $FRONTEND_URL"
echo ""
echo "Next steps:"
echo "1. Update the URLs in this script with your actual Render service URLs"
echo "2. Test the application thoroughly"
echo "3. Monitor logs in Render dashboard"
echo "4. Set up custom domains if needed"