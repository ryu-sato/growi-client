require 'growi/client/model/growi_model'

# Growi Page revision model class
class GrowiPageRevision < GrowiModelBase
  attr_reader :_id, :author, :body, :path, :__v, :createdAt, :format

  # Constractor
  # @param [Hash] User model shown as hash
  # @todo Except running register method always called parse method.
  def initialize(params = {})
    init_params = {
      _id: '', author: nil, body: nil, path: nil, __v: 0, createdAt: nil,
      format: ''
    }

    params = init_params.merge(params.map { |k,v| [k.to_sym, v] }.to_h)
    if (params[:_id] == nil ||  params[:path] == nil)
      raise ArgumentError.new('Parameters _id and path are required.')
    end

    GrowiModelFactory.instance.register({
      page_revision_createdAt: Proc.new { |date_str|
                                          date_str != nil && DateTime.parse(date_str) },
    })
    maked_params = {}
    params.each do |k,v|
      maker = GrowiModelFactory.instance.maker('page_revision_' + k.to_s)
      maked_params[k] = maker.call(v)
    end
    super(maked_params)
  end

end

