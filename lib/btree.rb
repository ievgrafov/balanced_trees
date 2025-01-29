class BTree
  Node = Struct.new(:values, :children)

  def initialize(factor: 2)
    @root = Node.new([], [])
    @factor = factor
  end

  def push(value)
    if root.values.empty?
      root.values << value
      return
    end

    internal_push_new_value(value, root)
  end

  def find(value)
    internal_find(value, root)
  end

  def upper_bound(value)
    internal_upper_bound(value, root)
  end

  def lower_bound(value)
    internal_lower_bound(value, root)
  end

  def drop_lower_than(value)
    internal_drop_lower_than(value, root)
  end

  def to_a
    current_level_nodes = [root]
    result = []
    while current_level_nodes.any? do
      result << current_level_nodes.map(&:values)
      current_level_nodes = current_level_nodes.flat_map(&:children).compact
    end
    result
  end

  def levels
    count_levels(root, 1)
  end

  private

  attr_reader :root, :factor

  def count_levels(node, current_level)
    return current_level if node.children.empty?

    count_levels(node.children.first, current_level + 1)
  end

  def internal_drop_lower_than(value, node)
    return if node.values.empty?

    # if all node values are smaller than given, we should put rightmost child here
    if node.values.last < value
      node.values = node.children.last&.values || []
      node.children = node.children.last&.children || []

      return internal_drop_lower_than(value, node)
    end

    # drop all values and subtrees that are smaller than given
    i = 0
    i += 1 while i < node.values.size && node.values[i] < value

    if i > 0 # means we should drop some values
      node.values = node.values[i..-1] || []
      node.children = node.children[i..-1] || []
    end

    internal_drop_lower_than(value, node.children.first) if node.children.any?
  end

  def internal_upper_bound(value, node)
    upper_bound_index = find_position_for_new_value(node.values, value)
    upper_bound_value = upper_bound_index >= node.values.size ? nil : node.values[upper_bound_index]

    # Return found el because... well... we found exactly it
    return upper_bound_value if upper_bound_value == value

    # We can't go further, just return value no matter if it's present or not
    return upper_bound_value if node.children.empty?

    # It means solution is in the last child or nowhere so we go further
    return internal_upper_bound(value, node.children.last) if upper_bound_value.nil?

    # We can try to find more precise bound by trying left subtree but if there's nothing return current result
    internal_upper_bound(value, node.children[upper_bound_index]) || upper_bound_value
  end

  def internal_lower_bound(value, node)
    upper_bound_index = find_position_for_new_value(node.values, value)

    # Return value if we simply found it
    return value if node.values[upper_bound_index] == value

    # Given value smaller than any in current list, we either look in left subtree or return nil if there's no one
    if upper_bound_index == 0
      return nil if node.children.empty?
      return internal_lower_bound(value, node.children[0])
    end

    lower_bound_index = upper_bound_index - 1
    lower_bound_value = node.values[lower_bound_index]

    return lower_bound_value if lower_bound_value == value || node.children.empty?

    internal_lower_bound(value, node.children[upper_bound_index]) || lower_bound_value
  end

  def internal_find(value, node)
    upper_bound_index = find_position_for_new_value(node.values, value)

    return node.values[upper_bound_index] if node.values[upper_bound_index] == value
    return nil if node.children.empty?

    internal_find(value, node.children[upper_bound_index])
  end

  def full?(node)
    node.values.count >= 2*factor - 1
  end

  def find_position_for_new_value(list, value)
    prev_index = list.size
    index = list.size - 1

    while index >= 0 do
      v = list[index]

      return index if v == value
      return prev_index if v < value

      prev_index = index
      index -= 1
    end

    0
  end

  def internal_push_new_value(value, node, parent: nil)
    node = split_node(node, parent, value) if full?(node)
    new_value_position = find_position_for_new_value(node.values, value)

    return false if node.values[new_value_position] == value
    return internal_push_new_value(value, node.children[new_value_position], parent: node) if node.children.any?

    insert_value_at_position(node.values, value, new_value_position)
  end

  def insert_value_at_position(list, value, position)
    index = list.size
    while index > position do
        list[index] = list[index - 1]
        index -= 1
    end
    list[position] = value
  end

  def push_value_with_children(node, value, left_node, right_node)
    values = node.values
    children = node.children
    index_for_left_node = find_position_for_new_value(values, value)
    insert_value_at_position(values, value, index_for_left_node)
    insert_value_at_position(children, left_node, index_for_left_node)
    children[index_for_left_node + 1] = right_node
  end

  def split_node(node, parent, new_value)
    values = node.values
    children = node.children
    pivot_index = node.values.size / 2
    pivot = values[pivot_index]
    left_node = Node.new(values[0..(pivot_index - 1)], children.any? ? children[0..pivot_index] : [])
    right_node = Node.new(values[(pivot_index + 1)..-1], children.any? ? children[(pivot_index + 1)..-1] : [])

    if parent
      push_value_with_children(parent, pivot, left_node, right_node)
    else
      node.values = [pivot]
      node.children = [left_node, right_node]
    end

    pivot > new_value ? left_node : right_node
  end
end
