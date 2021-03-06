module Sprig::Reap
  class TsortableHash < Hash
    include TSort

    alias tsort_each_node each_key

    def tsort_each_child(node, &block)
      begin
        fetch(node).each(&block)
      rescue KeyError
        dependency_parent = nil
        self.each {|model, dependencies| if dependencies.include?(node); dependency_parent = model; break; end}
        raise "Dependencies must be exported together. `#{dependency_parent.name}` requires `#{node.name}` which was not included in the models."
      end
    end

    def resolve_circular_habtm_dependencies!
      # When two models each have a `has_and_belongs_to_many` association pointing to the other,
      # it creates a circular dependency.  Based on Sprig documentation, we only need to define
      # the association in one direction
      # (https://github.com/vigetlabs/sprig#has-and-belongs-to-many), so we delete one of them.

      self.each do |(model, dependencies)|
        model.reflect_on_all_associations(:has_and_belongs_to_many).each do |association|
          if dependencies.include?(association.klass) && self[association.klass].present?
            self[association.klass] = self[association.klass] - [model]
          end
        end
      end
    end
  end
end
