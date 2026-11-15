/// The five states a slot chip can show and the one rule that picks one
/// (data-model.md, research R11).
enum SlotState { available, selected, fewLeft, full, past }

/// Precedence, highest first: `past` > `full` > `selected` > `fewLeft` >
/// `available`. `remaining` is null on an exclusive unit.
SlotState resolveSlotState({
  int? remaining,
  required int fewLeftThreshold,
  bool isPast = false,
  bool isSelected = false,
  bool isFull = false,
}) {
  if (isPast) return SlotState.past;
  if (isFull || remaining == 0) return SlotState.full;
  if (isSelected) return SlotState.selected;
  if (remaining != null && remaining <= fewLeftThreshold) {
    return SlotState.fewLeft;
  }
  return SlotState.available;
}
