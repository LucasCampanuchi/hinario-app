bool testNumber(String text) {
  bool isDouble = false;
  try {
    double.parse(text);
    isDouble = true;
  } catch (e) {
    isDouble = false;
  }

  return isDouble;
}
