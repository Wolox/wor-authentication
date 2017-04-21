#
# Class used in tests to keep track of amount of calls for a method in a klass.
#
# Example in a controller spec:
#
# before do
#   Spy.spy(controller, 'authenticate_entity')
#   perform_some_request
# end
#
# it 'calls authenticate_entity defined by the user' do
#   count = controller.spied_authenticate_entity_counter
#   expect(count).to be(1)
# end
#
class Spy

  # Defines a counter for the given method and overrides it to update
  # the counter in every call before being executed.
  def self.spy(klass, method)
    define_counter(klass, method)
    klass.singleton_class.class_eval do
      define_method(method) do |*args, &block|
        instance_variable_set("@spied_#{method}_counter", instance_variable_get("@spied_#{method}_counter") + 1)
        super(*args, &block)
      end
    end
  end

  # Defines a counter (and its getter) for the given method as an instance variable of the given klass.
  def self.define_counter(klass, method)
    klass.instance_variable_set("@spied_#{method}_counter".to_sym, 0)

    klass.singleton_class.class_eval do
      define_method("spied_#{method}_counter".to_sym) do
        instance_variable_get("@spied_#{method}_counter")
      end
    end
  end

end
