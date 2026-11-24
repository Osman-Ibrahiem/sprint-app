/// The six states a slot chip can show and the one rule that picks one
/// (data-model.md, research R11; decision 3 of refactor 000 added `inRange`).
enum SlotState { available, selected, fewLeft, full, past, inRange }

/// Precedence, highest first: `past` > `full` > `selected` > `inRange` >
/// `fewLeft` > `available`. `remaining` is null on an exclusive unit.
/// [isInRange] marks a chip between the first and last of a free-facility
/// range.
SlotState resolveSlotState({
  int? remaining,
  required int fewLeftThreshold,
  bool isPast = false,
  bool isSelected = false,
  bool isFull = false,
  bool isInRange = false,
}) {
  if (isPast) return SlotState.past;
  if (isFull || remaining == 0) return SlotState.full;
  if (isSelected) return SlotState.selected;
  if (isInRange) return SlotState.inRange;
  if (remaining != null && remaining <= fewLeftThreshold) {
    return SlotState.fewLeft;
  }
  return SlotState.available;
}
