# APIリクエストのバリデーションエラー
# @note rescue する必要はないので Exception クラスは継承しない
class CPInvalidRequest
  attr_reader :msg

  # コンストラクタ
  # @param [String] msg エラーメッセージ（原因と対策が分かるとよい）
  def initialize(msg)
    @msg = msg
  end

  # Convert string
  # @return [String] Message
  def to_s
    return @msg
  end
end

# APIリクエストの応答基本クラス
class CPApiReturn
  attr_accessor :ok, :data

  # Constractor
  # @param [String] ok Result of API
  def initialize(params = {})
    if (! params[:ok].is_a?(TrueClass) && ! params[:ok].is_a?(FalseClass))
      raise ArgumentError.new('Parameter ok is needed true or false.')
    end
    @ok = params[:ok]
    @data = params[:data]
  end

end

# APIリクエストの基本クラス
class CPApiRequestBase
  METHOD_GET = "GET"
  METHOD_POST = "POST"
  attr_reader :entry_point, :method, :param

  # コンストラクタ
  # @param [String] entry_point APIリクエストのエントリポイントとなるURLパス(ex. '/page.list')
  # @param [Enumerator] method APIリクエストのタイプ
  # @param [Hash] param APIリクエストのパラメータ
  def initialize(entry_point, method, param = {})
    @entry_point = entry_point
    @method = method
    @param = param.reject { |k, v| !v }
  end

  # パラメータを代入
  # @param [Hash] param APIリクエストのパラメータ
  def param=(param = {})
    @param = param
  end

  # パラメータのバリデーションチェックを行う
  # @return [true/false] バリデーションチェック結果
  def valid?
    return (!_invalid)
  end

  # パラメータのバリデーションチェックを行う
  # @return [true/false] バリデーションチェック結果
  def invalid?
    return (_invalid)
  end

  # バリデーションエラーの説明
  # @return [String] バリデーションエラーの説明
  def validation_msg
    return _invalid&.to_s
  end

  # リクエストを実行する
  # @param  [String] entry_point APIのエントリーポイントとなるURL（ex. http://localhost:3000/_api/pages.list）
  # @param  [Hash] rest_client_param RestClientのパラメータ
  # @return [String] リクエスト実行結果（CPApiReturnオブジェクト）
  def execute(entry_point, rest_client_param: {})

    if invalid?
      return validation_msg
    end

    case @method
    when 'GET'
      params = { method: :get, url: entry_point, headers: { params: @param } }.merge(rest_client_param)
    when 'POST'
      params = { method: :post, url: entry_point, content_type: :json, accept: :json,
                 headers: { params: @param.to_json } }.merge()
    end
    ret_json = RestClient::Request.execute params
    ret = JSON.parse(ret_json)
    return CPApiReturn.new(ok: ret['ok'], data: ret.reject { |k,v| k == 'ok' })
  end

protected

  # バリデーションエラーを取得する
  # @return [nil/CPInvalidRequest] バリデーションエラー結果
  def _invalid
    return CPInvalidRequest "Invalid API request.";
  end

end

