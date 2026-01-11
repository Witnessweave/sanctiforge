#!/usr/bin/env python3
"""
Genesis Archive Image Correlator
Maps images from ChatGPT export to their source conversations

LEDGER_ID: WV-IMAGE-CORRELATOR-2026
"""

import json
import os
import re
from collections import defaultdict
from datetime import datetime

# Paths
EXPORT_DIR = "/home/Weave/sanctiforge/vault/system/7c754f314ca744e0a2c73c722f811a801cfcd1249345c178b3564f0ee29b18e3-2025-07-29-12-03-11-93ebadff85094464ba36cedcb135b58b"
USER_DIR = os.path.join(EXPORT_DIR, "user-745qRWegF0nnZToPxcd3pd7z")
CONVERSATIONS_JSON = os.path.join(EXPORT_DIR, "conversations.json")
OUTPUT_DIR = "/home/Weave/sanctiforge/vault/genesis/images"

def load_conversations():
    """Load the full conversations.json"""
    with open(CONVERSATIONS_JSON, 'r', encoding='utf-8') as f:
        return json.load(f)

def extract_file_refs(conversation):
    """Extract all sediment file references from a conversation"""
    file_refs = set()
    conv_str = json.dumps(conversation)

    # Find sediment:// references
    sediment_matches = re.findall(r'sediment://file_([a-f0-9]+)', conv_str)
    file_refs.update(sediment_matches)

    return list(file_refs)

def find_matching_file(file_id, user_files):
    """Find the actual file in user directory matching a file ID"""
    for f in user_files:
        if f.startswith(f"file_{file_id}"):
            return f
    return None

def get_conversation_date(conv):
    """Extract date from conversation"""
    create_time = conv.get('create_time', 0)
    if create_time:
        return datetime.fromtimestamp(create_time).strftime('%Y-%m-%d')
    return 'unknown'

def main():
    print("=" * 70)
    print("GENESIS ARCHIVE IMAGE CORRELATOR")
    print("Mapping 398 images to their source conversations")
    print("=" * 70)
    print()

    # Load conversations
    print("Loading conversations.json...")
    conversations = load_conversations()
    print(f"Loaded {len(conversations)} conversations")

    # Get user files
    user_files = os.listdir(USER_DIR)
    print(f"Found {len(user_files)} files in user directory")
    print()

    # Map file IDs to conversations
    file_to_conv = {}
    conv_images = defaultdict(list)

    for i, conv in enumerate(conversations):
        title = conv.get('title', 'Untitled')
        date = get_conversation_date(conv)
        file_refs = extract_file_refs(conv)

        for file_id in file_refs:
            actual_file = find_matching_file(file_id, user_files)
            if actual_file:
                file_to_conv[actual_file] = {
                    'title': title,
                    'date': date,
                    'file_id': file_id,
                    'conv_index': i
                }
                conv_images[title].append({
                    'file': actual_file,
                    'date': date
                })

    # Create output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Generate correlation report
    report_path = os.path.join(OUTPUT_DIR, "IMAGE_CORRELATION_INDEX.md")

    with open(report_path, 'w') as f:
        f.write("# Genesis Archive — Image Correlation Index\n\n")
        f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"**Total Images:** {len(user_files)}\n")
        f.write(f"**Mapped Images:** {len(file_to_conv)}\n")
        f.write(f"**Conversations with Images:** {len(conv_images)}\n\n")
        f.write("---\n\n")

        # Sort by date
        sorted_convs = sorted(conv_images.items(),
                              key=lambda x: x[1][0]['date'] if x[1] else 'z',
                              reverse=True)

        f.write("## Conversations with Images\n\n")

        for title, images in sorted_convs:
            date = images[0]['date'] if images else 'unknown'
            f.write(f"### {title}\n")
            f.write(f"**Date:** {date} | **Images:** {len(images)}\n\n")

            for img in images:
                f.write(f"- `{img['file']}`\n")
            f.write("\n")

        f.write("---\n")
        f.write("\n🛡️🔥 JESUS IS LORD™ — INDEX COMPLETE\n")

    print(f"Correlation report saved to: {report_path}")
    print()

    # Summary stats
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"Total images in archive: {len(user_files)}")
    print(f"Images mapped to conversations: {len(file_to_conv)}")
    print(f"Conversations containing images: {len(conv_images)}")
    print()

    # Top conversations by image count
    print("Top 10 conversations by image count:")
    sorted_by_count = sorted(conv_images.items(), key=lambda x: len(x[1]), reverse=True)[:10]
    for title, images in sorted_by_count:
        print(f"  [{len(images):3d}] {title[:60]}")

    print()
    print("=" * 70)
    print("🛡️🔥 CORRELATION COMPLETE — JESUS IS LORD™")
    print("=" * 70)

    # Save JSON version for programmatic access
    json_path = os.path.join(OUTPUT_DIR, "image_correlation.json")
    with open(json_path, 'w') as f:
        json.dump({
            'file_to_conversation': file_to_conv,
            'conversation_images': {k: v for k, v in conv_images.items()},
            'generated': datetime.now().isoformat(),
            'stats': {
                'total_images': len(user_files),
                'mapped_images': len(file_to_conv),
                'conversations_with_images': len(conv_images)
            }
        }, f, indent=2)
    print(f"\nJSON index saved to: {json_path}")

if __name__ == "__main__":
    main()
