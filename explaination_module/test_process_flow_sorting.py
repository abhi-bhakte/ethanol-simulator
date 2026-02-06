"""
Test script to verify process flow sorting functionality
"""

# Process flow order (upstream to downstream)
PROCESS_FLOW_ORDER = [
    "F101_FeedFlow_Lhr",        # Feed inlet
    "F102_CoolantFlow_Lhr",     # Coolant inlet (parallel with T101)
    "T101_CoolantTemp_C",       # Coolant temperature (parallel with F102)
    "T102_JacketTemp_C",        # Jacket temperature
    "T103_CSTRTemp_C",          # CSTR reactor temperature
    "C101_EthanolConc_molL",    # Ethanol concentration
    "L101_CSTRLevel_m",         # CSTR level
    "F105_DistillFlow_Lhr",     # Distillation column flow
    "T106_Tray3Temp_C",         # Tray 3 temperature
    "T105_Tray5Temp_C",         # Tray 5 temperature
    "T104_Tray8Temp_C"          # Tray 8 temperature (bottom)
]

def sort_features_by_process_flow(features_list):
    """Sort features according to process flow order (upstream to downstream)."""
    flow_position = {name: idx for idx, name in enumerate(PROCESS_FLOW_ORDER)}
    return sorted(features_list, key=lambda x: flow_position.get(x['feature'], 999))


def test_sorting():
    """Test the sorting function with example data"""
    
    print("=" * 70)
    print("Testing Process Flow Sorting")
    print("=" * 70)
    
    # Example: Top 5 features by importance (random order)
    top_features_by_importance = [
        {"feature": "T104_Tray8Temp_C", "attribution": 0.85, "value": 95.2},
        {"feature": "F101_FeedFlow_Lhr", "attribution": 0.72, "value": 680.5},
        {"feature": "L101_CSTRLevel_m", "attribution": 0.68, "value": 1.15},
        {"feature": "T103_CSTRTemp_C", "attribution": 0.55, "value": 31.2},
        {"feature": "F102_CoolantFlow_Lhr", "attribution": 0.48, "value": 145.0}
    ]
    
    print("\nBefore sorting (by importance):")
    for i, feat in enumerate(top_features_by_importance, 1):
        print(f"  {i}. {feat['feature']:<25} | Attribution: {feat['attribution']:.2f}")
    
    # Sort by process flow
    top_features_by_flow = sort_features_by_process_flow(top_features_by_importance)
    
    print("\nAfter sorting (by process flow - upstream to downstream):")
    for i, feat in enumerate(top_features_by_flow, 1):
        print(f"  {i}. {feat['feature']:<25} | Attribution: {feat['attribution']:.2f}")
    
    print("\n" + "=" * 70)
    print("✓ Sorting test completed successfully!")
    print("=" * 70)
    
    # Verify the order is correct
    expected_order = ["F101_FeedFlow_Lhr", "F102_CoolantFlow_Lhr", 
                      "T103_CSTRTemp_C", "L101_CSTRLevel_m", "T104_Tray8Temp_C"]
    actual_order = [f['feature'] for f in top_features_by_flow]
    
    if actual_order == expected_order:
        print("✓ Features are correctly ordered by process flow!")
    else:
        print("✗ Warning: Order mismatch!")
        print(f"  Expected: {expected_order}")
        print(f"  Actual:   {actual_order}")


if __name__ == "__main__":
    test_sorting()
