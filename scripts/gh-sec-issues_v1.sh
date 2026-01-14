#!/bin/bash
# create-security-issues.sh
# Helper script to create GitHub issues from security findings

set -e

REPO="anotherk1nd/aws-portfolio"
GITHUB_URL="https://github.com/$REPO"

echo "🔒 Security Issue Creator"
echo "========================"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI not found. Install with: brew install gh"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "🔑 Please authenticate with GitHub:"
    gh auth login
fi

echo "📋 Current open security alerts:"
echo ""

# Fetch and display alerts
ALERTS=$(gh api "repos/$REPO/code-scanning/alerts?state=open" 2>/dev/null || echo "[]")

if [ "$ALERTS" = "[]" ] || [ -z "$ALERTS" ]; then
    echo "✅ No open security alerts found!"
    exit 0
fi

# Parse and display
echo "$ALERTS" | jq -r '.[] | "[\(.number)] \(.rule.severity) - \(.rule.id): \(.rule.description)"'

echo ""
read -p "Enter alert number to create issue (or 'all' for all): " ALERT_NUM

if [ "$ALERT_NUM" = "all" ]; then
    echo "Creating issues for all alerts..."
    
    echo "$ALERTS" | jq -c '.[]' | while read -r alert; do
        ALERT_ID=$(echo "$alert" | jq -r '.number')
        RULE_ID=$(echo "$alert" | jq -r '.rule.id')
        SEVERITY=$(echo "$alert" | jq -r '.rule.severity')
        DESCRIPTION=$(echo "$alert" | jq -r '.rule.description')
        FILE=$(echo "$alert" | jq -r '.most_recent_instance.location.path')
        LINE=$(echo "$alert" | jq -r '.most_recent_instance.location.start_line')
        
        SEVERITY_LOWER=$(echo "$SEVERITY" | tr '[:upper:]' '[:lower:]')
        
        BODY="**Finding:** $DESCRIPTION

**Location:** $FILE:$LINE
**Severity:** $SEVERITY
**Rule ID:** $RULE_ID
**Scanner:** Code Scanning

**Link:** $GITHUB_URL/security/code-scanning/$ALERT_ID

---

**Assessment:**
- [ ] Review finding
- [ ] Determine applicability  
- [ ] Decide: Fix / Suppress / Accept

**Decision:**
<!-- To be filled after review -->"

        echo "Creating issue for $RULE_ID..."
        
        gh issue create \
            --title "Security: $RULE_ID - $DESCRIPTION" \
            --body "$BODY" \
            --label "security,security-$SEVERITY_LOWER" \
            --assignee "@me"
        
        echo "✅ Issue created for alert #$ALERT_ID"
    done
    
    echo ""
    echo "✅ All issues created!"
    
else
    # Create single issue
    ALERT=$(echo "$ALERTS" | jq ".[] | select(.number==$ALERT_NUM)")
    
    if [ -z "$ALERT" ]; then
        echo "❌ Alert #$ALERT_NUM not found"
        exit 1
    fi
    
    RULE_ID=$(echo "$ALERT" | jq -r '.rule.id')
    SEVERITY=$(echo "$ALERT" | jq -r '.rule.severity')
    DESCRIPTION=$(echo "$ALERT" | jq -r '.rule.description')
    FILE=$(echo "$ALERT" | jq -r '.most_recent_instance.location.path')
    LINE=$(echo "$ALERT" | jq -r '.most_recent_instance.location.start_line')
    
    SEVERITY_LOWER=$(echo "$SEVERITY" | tr '[:upper:]' '[:lower:]')
    
    BODY="**Finding:** $DESCRIPTION

**Location:** $FILE:$LINE
**Severity:** $SEVERITY
**Rule ID:** $RULE_ID
**Scanner:** Code Scanning

**Link:** $GITHUB_URL/security/code-scanning/$ALERT_NUM

---

**Assessment:**
- [ ] Review finding
- [ ] Determine applicability
- [ ] Decide: Fix / Suppress / Accept

**Decision:**
<!-- To be filled after review -->"

    echo ""
    echo "Creating issue..."
    
    ISSUE_URL=$(gh issue create \
        --title "Security: $RULE_ID - $DESCRIPTION" \
        --body "$BODY" \
        --label "security,security-$SEVERITY_LOWER" \
        --assignee "@me")
    
    echo "✅ Issue created: $ISSUE_URL"
fi

echo ""
echo "🔗 View issues: $GITHUB_URL/issues?q=is:issue+is:open+label:security"
