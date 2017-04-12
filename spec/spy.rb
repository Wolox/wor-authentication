class Spy
  def self.spy(klass, method)
    define_counter(klass, method)
    klass.singleton_class.class_eval do
      define_method(method) do |*args, &block|
        instance_variable_set("@spied_#{method}_counter", instance_variable_get("@spied_#{method}_counter") + 1)
        super(*args, &block)
      end
    end
  end

  def self.define_counter(klass, method)
    klass.instance_variable_set("@spied_#{method}_counter".to_sym, 0)

    klass.singleton_class.class_eval do
      define_method("spied_#{method}_counter".to_sym) do
        instance_variable_get("@spied_#{method}_counter")
      end
    end
  end
end
