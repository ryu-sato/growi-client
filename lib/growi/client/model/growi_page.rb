require 'growi/client/model/growi_model'

# Growi Page model class
class GrowiPage < GrowiModelBase
  GRANT_PUBLIC     = 1.freeze
  GRANT_RESTRICTED = 2.freeze
  GRANT_SPECIFIED  = 3.freeze
  GRANT_OWNER      = 4.freeze

  STATUS_WIP        = 'wip'.freeze
  STATUS_PUBLISHED  = 'published'.freeze
  STATUS_DELETED    = 'deleted'.freeze
  STATUS_DEPRECATED = 'deprecated'.freeze

  attr_reader :_id, :redirectTo, :updatedAt, :lastUpdateUser,
              :creator, :path, :__v, :revision, :createdAt,
              :commentCount, :seenUsers, :liker, :grantedUsers,
              :grant, :status, :extended,
              :pageIdOnHackmd, :revisionHackmdSynced, :hasDraftOnHackmd

  # Constract
  # @param [Hash] params Prameters data show as Hash
  # @todo Except running register method always called parse method.
  def initialize(params = {})
    init_params = {
      _id: '', redirectTo: nil, updatedAt: '', lastUpdateUser: '',
      creator: nil, path: nil, __v: 0, revision: nil, createdAt: '',
      commentCount: 0, seenUsers: [], liker: [], grantedUsers: [],
      grant: 0, status: ''
    }
    params = init_params.merge(params.map { |k,v| [k.to_sym, v] }.to_h)
    if (params[:_id].nil?)
      raise ArgumentError.new('Parameter _id is required.')
    end

    # @note Parameters lastUpdateUser and creator have two patterns ID only or Object.
    GrowiModelFactory.instance.register({
      page_updatedAt:      Proc.new { |str| !str.nil? && str != "" ? DateTime.parse(str) : "" },
      page_lastUpdateUser: Proc.new { |param| !param.nil? && param.is_a?(String) ? param : GrowiUser.new(param) },
      page_creator:        Proc.new { |param| !param.nil? && param.is_a?(String) ? param : GrowiUser.new(param) },
      page_createdAt:      Proc.new { |str| !str.nil? && str != "" ? DateTime.parse(str) : "" },

      # revision が文字列のみ(IDだけの場合)であれば _id のみを格納し、ハッシュ化されていればすべて読み込む
      page_revision:       Proc.new { |param| !param.nil? && GrowiPageRevision.new(param.is_a?(String) ? { _id: param } : param) },
    })
    maked_params = {}
    params.each do |k,v|
      maker = GrowiModelFactory.instance.maker('page_' + k.to_s)
      maked_params[k] = maker.call(v)
    end
    super(maked_params)
  end

end
