import 'dart:math';

List randomizeSize(List items) {
  Random random = Random();
  final List result = []; 

  int multiply = random.nextInt(10);

  for (int x = 0; x < multiply; x++) {
    items.shuffle();
    result.addAll(items);
  }

  return result;
}
