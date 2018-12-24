require 'growi/client/model/growi_model'

# Growi User model class
class GrowiUser < GrowiModelBase
  attr_reader :_id, :email, :username, :name,
              :admin, :createdAt, :status, :lang, :isGravatarEnabled

  # Constractor
  # @param [Hash] User model shown as hash
  # @todo Except running register method always called parse method.
  def initialize(params = {})
    init_params = {
      _id: nil, email: nil, username: nil, name: '',
      admin: false, createdAt: '', status: 0, lang: '', isGravatarEnabled: false
    }

    params = init_params.merge(params.map { |k,v| [k.to_sym, v] }.to_h)
    if (params[:_id] == nil || params[:email] == nil || params[:username] == nil)
      raise ArgumentError.new('Parameters id and email and name are required.')
    end

    GrowiModelFactory.instance.register({
      user_createdAt: Proc.new { |date_str|
                        date_str != nil && DateTime.parse(date_str) },
    })
    maked_params = {}
    params.each do |k,v|
      maker = GrowiModelFactory.instance.maker('user_' + k.to_s)
      maked_params[k] = maker.call(v)
    end
    super(maked_params)
  end

end

