"""Extract widget classes from admin_dashboard_screen.dart into widgets/ folder."""
import os
import re

ROOT = os.path.join(os.path.dirname(__file__), '..', 'lib', 'screens', 'admin')
path = os.path.join(ROOT, 'admin_dashboard_screen.dart')
content = open(path, encoding='utf-8').read()

# Split at first widget class after state class ends
idx = content.find('\nclass _AdminNavItem')
if idx < 0:
    raise SystemExit('marker not found')

main_part = content[:idx].rstrip() + '\n'
widgets_part = content[idx + 1:]

widgets_dir = os.path.join(ROOT, 'widgets')
os.makedirs(widgets_dir, exist_ok=True)

# Map private class to file and public name
classes = [
    ('_AdminNavItem', 'admin_nav_item.dart', 'AdminNavItem'),
    ('_PendingProviderCard', 'pending_provider_card.dart', 'PendingProviderCard'),
    ('_PendingProviderCardState', 'pending_provider_card.dart', None),
    ('_ApprovedProviderCard', 'approved_provider_card.dart', 'ApprovedProviderCard'),
    ('_DocReviewTile', 'admin_shared_widgets.dart', 'AdminDocReviewTile'),
    ('_StepFlowIndicator', 'admin_shared_widgets.dart', 'AdminStepFlowIndicator'),
    ('_StepDot', 'admin_shared_widgets.dart', 'AdminStepDot'),
    ('_StepLine', 'admin_shared_widgets.dart', 'AdminStepLine'),
    ('_SectionHeader', 'admin_shared_widgets.dart', 'AdminSectionHeader'),
    ('_StatusChip', 'admin_shared_widgets.dart', 'AdminStatusChip'),
]

def extract_class(name, text):
    m = re.search(rf'\nclass {re.escape(name)}\b', text)
    if not m:
        return None, text
    start = m.start() + 1
  # find next class at column 0
    m2 = re.search(r'\nclass _', text[start:])
    end = start + m2.start() if m2 else len(text)
    return text[start:end].rstrip(), text[:start] + text[end:]

remaining = widgets_part
extracted = {}
for priv, file, pub in classes:
    block, remaining = extract_class(priv, remaining)
    if block is None:
        continue
    if pub:
        block = block.replace(f'class {priv}', f'class {pub}', 1)
        block = re.sub(rf'\b{priv[1:]}\b', pub, block)  # rough
    extracted.setdefault(file, []).append(block)

header = """import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/full_screen_image_viewer.dart';

"""

for file, blocks in extracted.items():
    body = '\n\n'.join(blocks)
    # fix PendingProviderCardState reference
    body = body.replace('State<PendingProviderCard>', 'State<PendingProviderCard>')
    body = body.replace('extends State<_PendingProviderCard>', 'extends State<PendingProviderCard>')
    body = body.replace('Widget _PendingProviderCard', 'Widget PendingProviderCard')
    out_path = os.path.join(widgets_dir, file)
    mode = 'a' if os.path.exists(out_path) else 'w'
    with open(out_path, mode, encoding='utf-8') as f:
        if mode == 'w':
            f.write(f'/// Admin dashboard widgets ({file}).\n')
            f.write(header)
        f.write(body + '\n')

# Update main file imports and class references
main_part = main_part.replace('_AdminNavItem', 'AdminNavItem')
main_part = main_part.replace('_PendingProviderCard', 'PendingProviderCard')
main_part = main_part.replace('_ApprovedProviderCard', 'ApprovedProviderCard')
main_part = main_part.replace('_StatusChip', 'AdminStatusChip')
main_part = main_part.replace('_SectionHeader', 'AdminSectionHeader')
main_part = main_part.replace('_DocReviewTile', 'AdminDocReviewTile')
main_part = main_part.replace('_StepFlowIndicator', 'AdminStepFlowIndicator')
main_part = main_part.replace('_StepDot', 'AdminStepDot')
main_part = main_part.replace('_StepLine', 'AdminStepLine')

imports = """import 'widgets/admin_nav_item.dart';
import 'widgets/pending_provider_card.dart';
import 'widgets/approved_provider_card.dart';
import 'widgets/admin_shared_widgets.dart';
"""
main_part = main_part.replace(
    "import 'support_requests_screen.dart';",
    "import 'support_requests_screen.dart';\n" + imports,
)

open(path, 'w', encoding='utf-8').write(main_part)
print('main lines', sum(1 for _ in open(path)))
print('remaining widget text', len(remaining))
