# Forms minimal heap by priority and btree on value
class Treap
  Node = Struct.new(:value, :priority, :left, :right)

  def initialize(value, priority, max_heap: false)
    @root = Node.new(value, priority, nil, nil)
    @heap_type = max_heap ? :max : :min
  end

  def push(value, priority)
    new_node = Node.new(value, priority, nil, nil)
    
    push_to_subtree(new_node, root)
  end

  def to_a(priority: false)
    current_level_leafs = [root]
    result = []
    field = priority ? :priority : :value

    while current_level_leafs.any? do
      result << current_level_leafs.map(&field)
      current_level_leafs = current_level_leafs.flat_map { |leaf| [leaf.left, leaf.right].compact }
    end

    result
  end

  def closest_with_min_priority(value, min_priority)
    closest_with_min_priority_in_subtree(value, min_priority, root)
  end

  def levels
    count_levels(root, 1)
  end

  def max_priority_between_values(value1, value2)

  end

  private

  attr_reader :root, :heap_type

  def count_levels(node, current_level)
    return current_level if node.right.nil? && node.left.nil?

    [node.right, node.left].compact.map { |child| count_levels(child, current_level + 1) }.max
  end

  def closest_with_min_priority_in_subtree(value, min_priority, node)
    if node.priority >= min_priority
      return find_closest_in_subtree(value, node)
    end

    left_best = closest_with_min_priority_in_subtree(value, min_priority, node.left) if node.left
    right_best = closest_with_min_priority_in_subtree(value, min_priority, node.right) if node.right

    [left_best, right_best].compact.min_by { |boundary| (boundary - value).abs }
  end

  def find_closest_in_subtree(value, node)
    return value if node.value == value

    [
      left_boundary_in_subtree(value, node),
      right_boundary_in_subtree(value, node)
    ].compact.min_by { |boundary| (boundary - value).abs }
  end

  def left_boundary_in_subtree(value, node)
    return node.value if value == node.value

    possible_values = []

    possible_values << node.value if node.value < value
    possible_values << left_boundary_in_subtree(value, node.left) if node.value > value && node.left
    possible_values << left_boundary_in_subtree(value, node.right) if node.value < value && node.right

    possible_values.compact.min_by { |boundary| (boundary - value).abs }
  end

  def right_boundary_in_subtree(value, node)
    return node.value if value == node.value

    possible_values = []

    possible_values << node.value if node.value > value
    possible_values << right_boundary_in_subtree(value, node.left) if node.value > value && node.left
    possible_values << right_boundary_in_subtree(value, node.right) if node.value < value && node.right

    possible_values.compact.min_by { |boundary| (boundary - value).abs }
  end

  def push_to_subtree(new_node, node)
    return if new_node.value == node.value

    if new_node.value > node.value
      if node.right
        push_to_subtree(new_node, node.right)
      else
        node.right = new_node
      end
    else
      if node.left
        push_to_subtree(new_node, node.left)
      else
        node.left = new_node
      end
    end

    ensure_heap_on_priority(node)
  end

  def heap_failed(left_node, right_node)
    case heap_type
    when :max
      left_node.priority < right_node.priority
    when :min
      left_node.priority > right_node.priority
    else
      raise "Wrong heap on prioruty type"
    end
  end

  def ensure_heap_on_priority(node)
    left_child = node.left
    right_child = node.right

    if left_child && heap_failed(node, left_child)
      right_node = Node.new(node.value, node.priority, left_child.right, node.right)
      node.value = left_child.value
      node.priority = left_child.priority
      node.left = left_child.left
      node.right = right_node
    end

    if right_child && heap_failed(node, right_child)
      left_node = Node.new(node.value, node.priority, node.left, right_child.left)
      node.value = right_child.value
      node.priority = right_child.priority
      node.left = left_node
      node.right = right_child.right
    end
  end
end
