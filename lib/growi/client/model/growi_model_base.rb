# Growi model base class
class GrowiModelBase

  # Constractor
  def initialize(params = {})
    params.each do |k,v|
      instance_variable_set(:"@#{k}", v)
    end
  end

end

