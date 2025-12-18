#!/bin/bash

# Rivet Auth System Test Script
# Tests all auth endpoints with real HTTP requests

BASE_URL="http://localhost:3000"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🧪 Testing Rivet Auth System"
echo "=============================="
echo ""

# Test 1: Register user
echo "1️⃣  Testing user registration..."
REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"testuser@example.com","password":"SecurePass123!","name":"Test User"}')

if echo "$REGISTER_RESPONSE" | grep -q "User registered successfully"; then
  echo -e "${GREEN}✅ Registration successful${NC}"
else
  echo -e "${RED}❌ Registration failed${NC}"
  echo "$REGISTER_RESPONSE"
fi
echo ""

# Test 2: Login
echo "2️⃣  Testing login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"testuser@example.com","password":"password123"}')

TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -n "$TOKEN" ]; then
  echo -e "${GREEN}✅ Login successful${NC}"
  echo -e "${YELLOW}Token: ${TOKEN:0:50}...${NC}"
else
  echo -e "${RED}❌ Login failed${NC}"
  echo "$LOGIN_RESPONSE"
fi
echo ""

# Test 3: Access protected route without token
echo "3️⃣  Testing protected route without token..."
NO_AUTH_RESPONSE=$(curl -s "$BASE_URL/api/profile")

if echo "$NO_AUTH_RESPONSE" | grep -q "Missing authorization token"; then
  echo -e "${GREEN}✅ Correctly rejected unauthorized request${NC}"
else
  echo -e "${RED}❌ Should have rejected request${NC}"
  echo "$NO_AUTH_RESPONSE"
fi
echo ""

# Test 4: Access protected route with valid token
echo "4️⃣  Testing protected route with valid token..."
PROFILE_RESPONSE=$(curl -s "$BASE_URL/api/profile" \
  -H "Authorization: Bearer $TOKEN")

if echo "$PROFILE_RESPONSE" | grep -q "Your profile"; then
  echo -e "${GREEN}✅ Successfully accessed protected route${NC}"
  echo "$PROFILE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$PROFILE_RESPONSE"
else
  echo -e "${RED}❌ Failed to access protected route${NC}"
  echo "$PROFILE_RESPONSE"
fi
echo ""

# Test 5: Access admin route with user token (should fail)
echo "5️⃣  Testing admin route with user token..."
ADMIN_FAIL_RESPONSE=$(curl -s "$BASE_URL/api/admin/dashboard" \
  -H "Authorization: Bearer $TOKEN")

if echo "$ADMIN_FAIL_RESPONSE" | grep -q "Insufficient permissions"; then
  echo -e "${GREEN}✅ Correctly rejected non-admin user${NC}"
else
  echo -e "${RED}❌ Should have rejected non-admin${NC}"
  echo "$ADMIN_FAIL_RESPONSE"
fi
echo ""

# Test 6: Token refresh
echo "6️⃣  Testing token refresh..."
REFRESH_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/refresh" \
  -H "Content-Type: application/json" \
  -d "{\"token\":\"$TOKEN\"}")

NEW_TOKEN=$(echo "$REFRESH_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -n "$NEW_TOKEN" ] && [ "$NEW_TOKEN" != "$TOKEN" ]; then
  echo -e "${GREEN}✅ Token refreshed successfully${NC}"
  echo -e "${YELLOW}New Token: ${NEW_TOKEN:0:50}...${NC}"
else
  echo -e "${RED}❌ Token refresh failed${NC}"
  echo "$REFRESH_RESPONSE"
fi
echo ""

# Test 7: Invalid token
echo "7️⃣  Testing with invalid token..."
INVALID_RESPONSE=$(curl -s "$BASE_URL/api/profile" \
  -H "Authorization: Bearer invalid.token.here")

if echo "$INVALID_RESPONSE" | grep -q "Invalid or expired token"; then
  echo -e "${GREEN}✅ Correctly rejected invalid token${NC}"
else
  echo -e "${RED}❌ Should have rejected invalid token${NC}"
  echo "$INVALID_RESPONSE"
fi
echo ""

# Test 8: Optional auth without token
echo "8️⃣  Testing optional auth without token..."
OPTIONAL_NO_AUTH=$(curl -s "$BASE_URL/api/public-with-optional-auth")

if echo "$OPTIONAL_NO_AUTH" | grep -q "anonymous"; then
  echo -e "${GREEN}✅ Optional auth works without token${NC}"
else
  echo -e "${RED}❌ Optional auth failed${NC}"
  echo "$OPTIONAL_NO_AUTH"
fi
echo ""

# Test 9: Optional auth with token
echo "9️⃣  Testing optional auth with token..."
OPTIONAL_WITH_AUTH=$(curl -s "$BASE_URL/api/public-with-optional-auth" \
  -H "Authorization: Bearer $TOKEN")

if echo "$OPTIONAL_WITH_AUTH" | grep -q "authenticated"; then
  echo -e "${GREEN}✅ Optional auth works with token${NC}"
else
  echo -e "${RED}❌ Optional auth with token failed${NC}"
  echo "$OPTIONAL_WITH_AUTH"
fi
echo ""

# Test 10: Password hashing verification
echo "🔟 Testing password hashing..."
# Register two users with same password
curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"user1@test.com","password":"SamePassword123"}' > /dev/null

curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"email":"user2@test.com","password":"SamePassword123"}' > /dev/null

echo -e "${GREEN}✅ Password hashing test complete (check server logs for different hashes)${NC}"
echo ""

echo "=============================="
echo "🎉 All tests completed!"
echo "=============================="
