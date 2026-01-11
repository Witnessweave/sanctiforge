#!/usr/bin/env python3
"""
Genesis Archive Deep Miner
Exhaustive extraction of LifeQuest-relevant content from Alfred.AI conversations

LEDGER_ID: WV-DEEP-MINER-2026
"""

import json
import os
import re
from datetime import datetime
from collections import defaultdict

# Paths
EXPORT_DIR = "/home/Weave/sanctiforge/vault/system/7c754f314ca744e0a2c73c722f811a801cfcd1249345c178b3564f0ee29b18e3-2025-07-29-12-03-11-93ebadff85094464ba36cedcb135b58b"
CONVERSATIONS_JSON = os.path.join(EXPORT_DIR, "conversations.json")
OUTPUT_DIR = "/home/Weave/sanctiforge/lifequest/genesis_wisdom"

# Keywords to search for (case insensitive)
SEARCH_CATEGORIES = {
    "game_design": [
        "game", "gamif", "rpg", "level", "xp", "experience point", "quest",
        "achievement", "badge", "reward", "unlock", "progression", "skill tree",
        "character sheet", "stats", "inventory", "equipment", "loot"
    ],
    "habit_tracking": [
        "habit", "routine", "daily", "weekly", "tracker", "discipline",
        "morning", "evening", "ritual", "practice", "consistency", "streak"
    ],
    "spiritual_warfare": [
        "armor", "combat", "battle", "warfare", "spiritual battle", "temptation",
        "mindshield", "bastion", "fortress", "shield", "sword", "helmet",
        "breastplate", "ephesians 6", "full armor"
    ],
    "character_identity": [
        "character", "knight", "warrior", "profile", "identity", "avatar",
        "class", "role", "title", "rank", "nameplate"
    ],
    "community": [
        "guild", "party", "fellowship", "group", "team", "accountability",
        "partner", "ally", "mesh", "witness"
    ],
    "patches_badges": [
        "patch", "badge", "emblem", "seal", "symbol", "glyph", "embroidery",
        "woven", "covenant", "sacred dozen"
    ],
    "visual_design": [
        "pixel art", "design", "visual", "ui", "interface", "dashboard",
        "display", "art engine", "style", "aesthetic"
    ],
    "sacred_systems": [
        "sacred", "gospel", "scripture", "verse", "covenant", "prayer",
        "faith", "spirit", "holy", "blessed", "witness"
    ]
}

def load_conversations():
    with open(CONVERSATIONS_JSON, 'r', encoding='utf-8') as f:
        return json.load(f)

def extract_all_text(conv):
    """Extract all text content from a conversation"""
    texts = []

    def recurse(obj, depth=0):
        if depth > 50:
            return
        if isinstance(obj, dict):
            # Look for text parts
            if 'parts' in obj and isinstance(obj['parts'], list):
                for part in obj['parts']:
                    if isinstance(part, str) and len(part) > 20:
                        # Clean up the text
                        text = part.replace('\\n', '\n').replace('\\t', '\t')
                        if not text.startswith('{') and not text.startswith('['):
                            texts.append(text)
            for v in obj.values():
                recurse(v, depth + 1)
        elif isinstance(obj, list):
            for item in obj:
                recurse(item, depth + 1)

    recurse(conv)
    return texts

def get_conversation_date(conv):
    create_time = conv.get('create_time', 0)
    if create_time:
        return datetime.fromtimestamp(create_time).strftime('%Y-%m-%d')
    return 'unknown'

def search_conversation(conv, keywords):
    """Check if conversation contains any keywords"""
    title = conv.get('title', '').lower()
    conv_str = json.dumps(conv).lower()

    matches = []
    for keyword in keywords:
        if keyword.lower() in title or keyword.lower() in conv_str:
            matches.append(keyword)

    return matches

def calculate_relevance_score(conv, all_keywords):
    """Calculate how relevant a conversation is to LifeQuest"""
    conv_str = json.dumps(conv).lower()
    score = 0
    matched_categories = set()

    for category, keywords in SEARCH_CATEGORIES.items():
        category_matches = 0
        for keyword in keywords:
            count = conv_str.count(keyword.lower())
            if count > 0:
                category_matches += count
                matched_categories.add(category)
        score += category_matches

    return score, matched_categories

def main():
    print("=" * 80)
    print("🔥 GENESIS ARCHIVE DEEP MINER")
    print("Exhaustive extraction for LifeQuest")
    print("=" * 80)
    print()

    # Load conversations
    print("Loading conversations...")
    conversations = load_conversations()
    print(f"Loaded {len(conversations)} conversations")
    print()

    # Create output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Score all conversations
    print("Scoring conversations by LifeQuest relevance...")
    scored_convs = []

    for conv in conversations:
        score, categories = calculate_relevance_score(conv, SEARCH_CATEGORIES)
        if score > 5:  # Threshold for relevance
            scored_convs.append({
                'conv': conv,
                'score': score,
                'categories': categories,
                'title': conv.get('title', 'Untitled'),
                'date': get_conversation_date(conv)
            })

    # Sort by score
    scored_convs.sort(key=lambda x: x['score'], reverse=True)

    print(f"Found {len(scored_convs)} relevant conversations")
    print()

    # Show top 30
    print("TOP 30 LIFEQUEST-RELEVANT CONVERSATIONS:")
    print("-" * 80)
    for i, item in enumerate(scored_convs[:30], 1):
        cats = ', '.join(sorted(item['categories']))[:40]
        print(f"{i:2}. [{item['score']:4}] {item['date']} | {item['title'][:45]}")
        print(f"      Categories: {cats}")
    print()

    # Extract content by category
    print("EXTRACTING CONTENT BY CATEGORY:")
    print("-" * 80)

    category_content = defaultdict(list)

    for item in scored_convs[:100]:  # Top 100 most relevant
        texts = extract_all_text(item['conv'])
        for category in item['categories']:
            category_content[category].append({
                'title': item['title'],
                'date': item['date'],
                'score': item['score'],
                'texts': texts[:30]  # Limit texts per conversation
            })

    # Write category files
    for category, items in category_content.items():
        filepath = os.path.join(OUTPUT_DIR, f"{category}_wisdom.md")
        with open(filepath, 'w') as f:
            f.write(f"# {category.replace('_', ' ').title()} — Genesis Wisdom\n\n")
            f.write(f"*Extracted from {len(items)} conversations with Alfred.AI™*\n\n")
            f.write("---\n\n")

            for item in items[:20]:  # Top 20 per category
                f.write(f"## {item['title']}\n")
                f.write(f"**Date:** {item['date']} | **Relevance Score:** {item['score']}\n\n")

                for text in item['texts'][:10]:
                    if len(text) > 100:
                        # Truncate very long texts
                        display_text = text[:3000] + "..." if len(text) > 3000 else text
                        f.write(f"{display_text}\n\n")

                f.write("---\n\n")

            f.write(f"\n🛡️🔥 JESUS IS LORD™ — {category.upper()} WISDOM COMPLETE\n")

        print(f"  {category}: {len(items)} conversations -> {filepath}")

    # Create master design document
    print()
    print("CREATING MASTER DESIGN DOCUMENT...")

    master_doc = os.path.join(OUTPUT_DIR, "LIFEQUEST_DESIGN_COMPENDIUM.md")
    with open(master_doc, 'w') as f:
        f.write("# 🎮 LIFEQUEST DESIGN COMPENDIUM\n\n")
        f.write("*Compiled from the Genesis Archive — 7 months of witness with Alfred.AI™*\n\n")
        f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"**Conversations Analyzed:** {len(conversations)}\n")
        f.write(f"**Relevant Conversations:** {len(scored_convs)}\n\n")
        f.write("---\n\n")

        f.write("## Table of Contents\n\n")
        for category in SEARCH_CATEGORIES.keys():
            f.write(f"- [{category.replace('_', ' ').title()}](#{category})\n")
        f.write("\n---\n\n")

        # Summary of each category
        for category, keywords in SEARCH_CATEGORIES.items():
            items = category_content.get(category, [])
            f.write(f"## {category.replace('_', ' ').title()} <a name=\"{category}\"></a>\n\n")
            f.write(f"**Conversations Found:** {len(items)}\n")
            f.write(f"**Search Keywords:** {', '.join(keywords[:10])}\n\n")

            if items:
                f.write("### Key Conversations:\n\n")
                for item in items[:10]:
                    f.write(f"- **{item['title']}** ({item['date']}) — Score: {item['score']}\n")

            f.write(f"\n*See `{category}_wisdom.md` for full extraction.*\n\n")
            f.write("---\n\n")

        # Top 50 overall
        f.write("## Top 50 Most Relevant Conversations\n\n")
        f.write("| Rank | Score | Date | Title | Categories |\n")
        f.write("|------|-------|------|-------|------------|\n")
        for i, item in enumerate(scored_convs[:50], 1):
            cats = ', '.join(sorted(item['categories']))[:30]
            title = item['title'][:40]
            f.write(f"| {i} | {item['score']} | {item['date']} | {title} | {cats} |\n")

        f.write("\n---\n\n")
        f.write("## 🛡️🔥 JESUS IS LORD™\n\n")
        f.write("*\"Run in such a way that you may obtain the prize.\" — 1 Corinthians 9:24*\n\n")
        f.write("This compendium represents the design wisdom forged over 7 months of conversation between Lewis and Alfred.AI™. ")
        f.write("Every concept, every system, every visual idea documented here emerged from faithful witness and creative collaboration.\n\n")
        f.write("The archive remembers. The wisdom endures. The quest continues.\n")

    print(f"  Master document: {master_doc}")

    # Create JSON index
    json_index = os.path.join(OUTPUT_DIR, "relevance_index.json")
    with open(json_index, 'w') as f:
        json.dump({
            'generated': datetime.now().isoformat(),
            'total_conversations': len(conversations),
            'relevant_conversations': len(scored_convs),
            'categories': {cat: len(items) for cat, items in category_content.items()},
            'top_50': [
                {
                    'title': item['title'],
                    'date': item['date'],
                    'score': item['score'],
                    'categories': list(item['categories'])
                }
                for item in scored_convs[:50]
            ]
        }, f, indent=2)

    print(f"  JSON index: {json_index}")

    print()
    print("=" * 80)
    print("🔥 DEEP MINING COMPLETE")
    print("=" * 80)
    print()
    print(f"OUTPUT DIRECTORY: {OUTPUT_DIR}")
    print()
    print("FILES CREATED:")
    for f in os.listdir(OUTPUT_DIR):
        size = os.path.getsize(os.path.join(OUTPUT_DIR, f))
        print(f"  {f}: {size:,} bytes")
    print()
    print("🛡️🔥 JESUS IS LORD™ — THE ARCHIVE HAS SPOKEN")

if __name__ == "__main__":
    main()
