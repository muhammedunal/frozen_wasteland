import 'dart:collection';
import 'dart:math' as math;

import '../../config/constants.dart';
import '../../models/building.dart';
import 'collision_detection.dart';

/// A grid coordinate used by the pathfinder.
class GridNode {
  final int x;
  final int y;
  const GridNode(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is GridNode && other.x == x && other.y == y;

  @override
  int get hashCode => x * 73856093 ^ y * 19349663;

  @override
  String toString() => '($x,$y)';
}

/// A* pathfinding over the square isometric grid.
///
/// Buildings act as impassable obstacles. Movement is 4-directional by default;
/// set [allowDiagonal] to permit 8-directional movement.
class Pathfinding {
  Pathfinding._();

  /// Finds a path from [start] to [goal], returning the list of nodes
  /// (inclusive of both endpoints) or an empty list if unreachable.
  static List<GridNode> findPath(
    GridNode start,
    GridNode goal,
    List<Building> buildings, {
    bool allowDiagonal = false,
  }) {
    if (start == goal) return [start];
    if (!_walkable(goal.x, goal.y, buildings)) return const [];

    final open = _PriorityQueue();
    final cameFrom = <GridNode, GridNode>{};
    final gScore = <GridNode, double>{start: 0.0};

    open.add(start, _heuristic(start, goal));

    while (!open.isEmpty) {
      final current = open.removeFirst();
      if (current == goal) {
        return _reconstruct(cameFrom, current);
      }

      for (final neighbor in _neighbors(current, buildings, allowDiagonal)) {
        final tentative = (gScore[current] ?? GameConstants.maxPathCost) +
            _moveCost(current, neighbor);
        if (tentative < (gScore[neighbor] ?? GameConstants.maxPathCost)) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentative;
          open.addOrUpdate(neighbor, tentative + _heuristic(neighbor, goal));
        }
      }
    }
    return const [];
  }

  static List<GridNode> _reconstruct(
    Map<GridNode, GridNode> cameFrom,
    GridNode current,
  ) {
    final path = <GridNode>[current];
    var node = current;
    while (cameFrom.containsKey(node)) {
      node = cameFrom[node]!;
      path.add(node);
    }
    return path.reversed.toList();
  }

  static List<GridNode> _neighbors(
    GridNode node,
    List<Building> buildings,
    bool allowDiagonal,
  ) {
    const cardinals = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];
    const diagonals = [
      [1, 1],
      [1, -1],
      [-1, 1],
      [-1, -1],
    ];
    final dirs = allowDiagonal ? [...cardinals, ...diagonals] : cardinals;

    final result = <GridNode>[];
    for (final d in dirs) {
      final nx = node.x + d[0];
      final ny = node.y + d[1];
      if (_walkable(nx, ny, buildings)) {
        result.add(GridNode(nx, ny));
      }
    }
    return result;
  }

  static bool _walkable(int x, int y, List<Building> buildings) {
    if (x < 0 ||
        y < 0 ||
        x >= GameConstants.gridSize ||
        y >= GameConstants.gridSize) {
      return false;
    }
    return !CollisionDetection.isTileOccupied(x, y, buildings);
  }

  static double _moveCost(GridNode a, GridNode b) {
    final dx = (a.x - b.x).abs();
    final dy = (a.y - b.y).abs();
    return (dx + dy == 2) ? math.sqrt2 : 1.0;
  }

  /// Manhattan distance heuristic (admissible for 4-directional movement).
  static double _heuristic(GridNode a, GridNode b) {
    return ((a.x - b.x).abs() + (a.y - b.y).abs()).toDouble();
  }
}

/// Minimal binary-heap priority queue keyed by float priority.
class _PriorityQueue {
  final List<_Entry> _heap = [];
  final HashMap<GridNode, int> _index = HashMap();

  bool get isEmpty => _heap.isEmpty;

  void add(GridNode node, double priority) {
    _heap.add(_Entry(node, priority));
    _index[node] = _heap.length - 1;
    _siftUp(_heap.length - 1);
  }

  void addOrUpdate(GridNode node, double priority) {
    final existing = _index[node];
    if (existing == null) {
      add(node, priority);
    } else {
      _heap[existing] = _Entry(node, priority);
      _siftUp(existing);
      _siftDown(existing);
    }
  }

  GridNode removeFirst() {
    final first = _heap.first;
    final last = _heap.removeLast();
    _index.remove(first.node);
    if (_heap.isNotEmpty) {
      _heap[0] = last;
      _index[last.node] = 0;
      _siftDown(0);
    }
    return first.node;
  }

  void _siftUp(int i) {
    while (i > 0) {
      final parent = (i - 1) >> 1;
      if (_heap[i].priority >= _heap[parent].priority) break;
      _swap(i, parent);
      i = parent;
    }
  }

  void _siftDown(int i) {
    final n = _heap.length;
    while (true) {
      final left = 2 * i + 1;
      final right = 2 * i + 2;
      var smallest = i;
      if (left < n && _heap[left].priority < _heap[smallest].priority) {
        smallest = left;
      }
      if (right < n && _heap[right].priority < _heap[smallest].priority) {
        smallest = right;
      }
      if (smallest == i) break;
      _swap(i, smallest);
      i = smallest;
    }
  }

  void _swap(int a, int b) {
    final tmp = _heap[a];
    _heap[a] = _heap[b];
    _heap[b] = tmp;
    _index[_heap[a].node] = a;
    _index[_heap[b].node] = b;
  }
}

class _Entry {
  final GridNode node;
  final double priority;
  const _Entry(this.node, this.priority);
}
