require_relative 'api_request_base'
require 'growi/client/model/growi_page'
require 'growi/client/logger'

# ページ一覧リクエスト用クラス
# @ref https://github.com/weseek/growi/blob/master/src/server/routes/page.js
class GApiRequestPagesList < GApiRequestBase

  # コンストラクタ
  # @override
  # @param [Hash] param APIリクエストのパラメータ
  def initialize(param = {})
    super('/_api/pages.list', METHOD_GET,
          { path: param[:path_exp], user: param[:user] })
  end

  # リクエストを実行する
  # [TODO] pagination に対応する
  # @override
  # @param  [String] entry_point APIのエントリーポイントとなるURL（ex. http://localhost:3000/_api/pages.list）
  # @param  [Hash] rest_client_param RestClientのパラメータ
  # @return [Array] リクエスト実行結果
  def execute(entry_point, rest_client_param: {})

    if invalid?
      return validation_msg
    end

    params = { method: :get, url: entry_point, headers: { params: @param } }.merge(rest_client_param)
    GCLogger.logger.debug('Request: ' + params.to_s)

    begin
      raw_ret = RestClient::Request.execute params
      GCLogger.logger.debug('Return: ' + raw_ret.to_s)
      ret = JSON.parse raw_ret
    rescue Exception => e
      GCLogger.logger.error(e)
      return GCInvalidRequest.new "Unknown error occured: #{e}"
    end

    if (!ret['ok'].nil? && ret['ok'] == false)
      return GCInvalidRequest.new "API return false with msg: #{ret['msg']}"
    end

    begin
      pages = []
      ret['pages'].each do |page|
        pages.push(GrowiPage.new(page))
      end
      return GApiReturn.new(ok: ret['ok'], data: pages)
    rescue Exception => e
      GCLogger.logger.error(e)
      return GCInvalidRequest.new "Fail to parse: #{e}"
    end
  end

protected

  # バリデーションエラーを取得する
  # @override
  # @return [nil/GCInvalidRequest] バリデーションエラー結果
  def _invalid
    if ! (@param[:path] || @param[:user])
      return GCInvalidRequest.new 'Parameter path or user is required.'
    end
    if (@param[:path] && @param[:user])
      return GCInvalidRequest.new 'Parameter path and user can not be specified both.'
    end
  end

end


# ページ取得リクエスト用クラス
# @ref https://github.com/growi/growi/blob/master/lib/routes/page.js
class GApiRequestPagesGet < GApiRequestBase

  # コンストラクタ
  # @override
  # @param [Hash] param APIリクエストのパラメータ
  def initialize(param = {})
    super('/_api/pages.get', METHOD_GET,
          { page_id: param[:page_id], 
            path: param[:path], revision_id: param[:revision_id] })
  end

  # リクエストを実行する
  # @override
  # @param  [String] entry_point APIのエントリーポイントとなるURL（ex. http://localhost:3000/_api/pages.list）
  # @param  [Hash] rest_client_param RestClientのパラメータ
  # @return [Array] リクエスト実行結果
  def execute(entry_point, rest_client_param: {})

    if invalid?
      return validation_msg
    end

    params = { method: :get, url: entry_point, headers: { params: @param } }.merge(rest_client_param)
    GCLogger.logger.debug('Request: ' + params.to_s)

    begin
      raw_ret = RestClient::Request.execute params
      GCLogger.logger.debug('Return: ' + raw_ret.to_s)
      ret = JSON.parse raw_ret
    rescue Exception => e
      GCLogger.logger.error(e)
      return GCInvalidRequest.new "Unknown error occured: #{e}"
    end

    if (!ret['ok'].nil? && ret['ok'] == false)
      return GCInvalidRequest.new "API return false with msg: #{ret['msg']}"
    end

    return GApiReturn.new(ok: ret['ok'], data: GrowiPage.new(ret['page']))
  end

protected

  # バリデーションエラーを取得する
  # @override
  # @return [nil/GCInvalidRequest] バリデーションエラー結果
  def _invalid
    if ! (@param[:path] || @param[:page_id]) 
      return GCInvalidRequest.new 'Parameter path or page_id is required.'
    end
  end

end


# ページ作成リクエスト用クラス
# @ref https://github.com/growi/growi/blob/master/lib/routes/page.js
class GApiRequestPagesCreate < GApiRequestBase

  # コンストラクタ
  # @override
  # @param [Hash] param APIリクエストのパラメータ
  def initialize(param = {})
    super('/_api/pages.create', METHOD_POST,
          { body: param[:body], path: param[:path], grant: param[:grant] })
  end

  # リクエストを実行する
  # @override
  # @param  [String] entry_point APIのエントリーポイントとなるURL（ex. http://localhost:3000/_api/pages.list）
  # @param  [Hash] rest_client_param RestClientのパラメータ
  # @return [Array] リクエスト実行結果
  def execute(entry_point, rest_client_param: {})

    if invalid?
      return validation_msg
    end

    params = { method: :post, url: entry_point,
               payload: @param.to_json,
               headers: { content_type: :json, accept: :json }
             }.merge(rest_client_param)
    GCLogger.logger.debug('Request: ' + params.to_s)

    begin
      raw_ret = RestClient::Request.execute params
      GCLogger.logger.debug('Return: ' + raw_ret.to_s)
      ret = JSON.parse raw_ret
    rescue Exception => e
      GCLogger.logger.error(e)
      return GCInvalidRequest.new "Unknown error occured: #{e}"
    end

    if (!ret['ok'].nil? && ret['ok'] == false)
      return GCInvalidRequest.new "API return false with msg: #{ret['msg']}"
    end

    return GApiReturn.new(ok: ret['ok'], data: GrowiPage.new(ret['page']))
  end

protected

  # バリデーションエラーを取得する
  # @override
  # @return [nil/GCInvalidRequest] バリデーションエラー結果
  def _invalid
    if ! (@param[:body] && @param[:path]) 
      return GCInvalidRequest.new 'Parameters body and path are required.'
    end
  end

end

# ページ更新リクエスト用クラス
# @ref https://github.com/growi/growi/blob/master/lib/routes/page.js
class GApiRequestPagesUpdate < GApiRequestBase

  # コンストラクタ
  # @override
  # @param [Hash] param APIリクエストのパラメータ
  def initialize(param = {})
    super('/_api/pages.update', METHOD_POST,
          { body: param[:body], page_id: param[:page_id],
            revision_id: param[:revision_id], grant: param[:grant] })
  end

  # リクエストを実行する
  # @override
  # @param  [String] entry_point APIのエントリーポイントとなるURL（ex. http://localhost:3000/_api/pages.list）
  # @param  [Hash] rest_client_param RestClientのパラメータ
  # @return [Array] リクエスト実行結果
  def execute(entry_point, rest_client_param: {})

    if invalid?
      return validation_msg
    end
    params = { method: :post, url: entry_point,
               payload: @param.to_json,
               headers: { content_type: :json, accept: :json }
             }.merge(rest_client_param)
    GCLogger.logger.debug('Request: ' + params.to_s)

    begin
      raw_ret = RestClient::Request.execute params
      GCLogger.logger.debug('Return: ' + raw_ret.to_s)
      ret = JSON.parse raw_ret
    rescue Exception => e
      GCLogger.logger.error(e)
      return GCInvalidRequest.new "Unknown error occured: #{e}"
    end

    if (!ret['ok'].nil? && ret['ok'] == false)
      return GCInvalidRequest.new "API return false with msg: #{ret['msg']}"
    end

    return GApiReturn.new(ok: ret['ok'], data: GrowiPage.new(ret['page']))
  end

protected

  # バリデーションエラーを取得する
  # @override
  # @return [nil/GCInvalidRequest] バリデーションエラー結果
  def _invalid
    if ! (@param[:page_id] && @param[:revision_id] && @param[:body])
      return GCInvalidRequest.new 'Parameters page_id, revision_id and body are required.'
    end
  end

end

# ページ閲覧済マークを付与リクエスト用クラス
# @ref https://github.com/growi/growi/blob/master/lib/routes/page.js
# @note 詳細不明
class GApiRequestPagesSeen < GApiRequestBase

  # コンストラクタ
  # @override
  # @param [Hash] param APIリクエストのパラメータ
  def initialize(param = {})
    super('/_api/pages.seen', METHOD_POST, { page_id: param[:page_id] })
  end

  # リクエストを実行する
  # @override
  # @param  [String] entry_point APIのエントリーポイントとなるURL（ex. http://localhost:3000/_api/pages.list）
  # @param  [Hash] rest_client_param RestClientのパラメータ
  # @return [Array] リクエスト実行結果
  def execute(entry_point, rest_client_param: {})

    if invalid?
      return validation_msg
    end
    params = { method: :post, url: entry_point,
               payload: @param.to_json,
               headers: { content_type: :json, accept: :json }
             }.merge(rest_client_param)
    GCLogger.logger.debug('Request: ' + params.to_s)

    begin
      raw_ret = RestClient::Request.execute params
      GCLogger.logger.debug('Return: ' + raw_ret.to_s)
      ret = JSON.parse raw_ret
    rescue Exception => e
      GCLogger.logger.error(e)
      return GCInvalidRequest.new "Unknown error occured: #{e}"
    end

    if (!ret['ok'].nil? && ret['ok'] == false)
      return GCInvalidRequest.new "API return false with msg: #{ret['msg']}"
    end

    begin
      users = ret['seenUser'].map do |user|
        user.is_a?(String) ? user : GrowiUser.new(user)
      end
      return GApiReturn.new(ok: ret['ok'], data: users)
    rescue Exception => e
      GCLogger.logger.error(e)
      return GCInvalidRequest.new "Fail to parse: #{e}"
    end
  end

protected

  # バリデーションエラーを取得する
  # @override
  # @return [nil/GCInvalidRequest] バリデーションエラー結果
  def _invalid
    if ! (@param[:page_id]) 
      return GCInvalidRequest.new 'Parameter page_id required.'
    end
  end

end

# ライクページ指定リクエスト用クラス
# @ref https://github.com/growi/growi/blob/master/lib/routes/page.js
class GApiRequestLikesAdd < GApiRequestBase

  # コンストラクタ
  # @override
  # @param [Hash] param APIリクエストのパラメータ
  def initialize(param = {})
    super('/_api/likes.add', METHOD_POST, { page_id: param[:page_id] })
  end

  # リクエストを実行する
  # @override
  # @param  [String] entry_point APIのエントリーポイントとなるURL（ex. http://localhost:3000/_api/pages.list）
  # @param  [Hash] rest_client_param RestClientのパラメータ
  # @return [Array] リクエスト実行結果
  def execute(entry_point, rest_client_param: {})

    if invalid?
      return validation_msg
    end

    params = { method: :post, url: entry_point,
               payload: @param.to_json,
               headers: { content_type: :json, accept: :json }
             }.merge(rest_client_param)
    GCLogger.logger.debug('Request: ' + params.to_s)

    begin
      raw_ret = RestClient::Request.execute params
      GCLogger.logger.debug('Return: ' + raw_ret.to_s)
      ret = JSON.parse raw_ret
    rescue Exception => e
      GCLogger.logger.error(e)
      return GCInvalidRequest.new "Unknown error occured: #{e}"
    end

    if (!ret['ok'].nil? && ret['ok'] == false)
      return GCInvalidRequest.new "API return false with msg: #{ret['msg']}"
    end

    return GApiReturn.new(ok: ret['ok'], data: GrowiPage.new(ret['page']))
  end

protected

  # バリデーションエラーを取得する
  # @override
  # @return [nil/GCInvalidRequest] バリデーションエラー結果
  def _invalid
    if ! (@param[:page_id]) 
      return GCInvalidRequest.new 'Parameter page_id required.'
    end
  end

end

# ライクページ指定解除リクエスト用クラス
# @ref https://github.com/growi/growi/blob/master/lib/routes/page.js
class GApiRequestLikesRemove < GApiRequestBase

  # コンストラクタ
  # @override
  # @param [Hash] param APIリクエストのパラメータ
  def initialize(param = {})
    super('/_api/likes.remove', METHOD_POST, { page_id: param[:page_id] })
  end

  # リクエストを実行する
  # @override
  # @param  [String] entry_point APIのエントリーポイントとなるURL（ex. http://localhost:3000/_api/pages.list）
  # @param  [Hash] rest_client_param RestClientのパラメータ
  # @return [Array] リクエスト実行結果
  def execute(entry_point, rest_client_param: {})

    if invalid?
      return validation_msg
    end
    params = { method: :post, url: entry_point,
               payload: @param.to_json,
               headers: { content_type: :json, accept: :json }
             }.merge(rest_client_param)
    GCLogger.logger.debug('Request: ' + params.to_s)

    begin
      raw_ret = RestClient::Request.execute params
      GCLogger.logger.debug('Return: ' + raw_ret.to_s)
      ret = JSON.parse raw_ret
    rescue Exception => e
      GCLogger.logger.error(e)
      return GCInvalidRequest.new "Unknown error occured: #{e}"
    end

    if (!ret['ok'].nil? && ret['ok'] == false)
      return GCInvalidRequest.new "API return false with msg: #{ret['msg']}"
    end

    return GApiReturn.new(ok: ret['ok'], data: GrowiPage.new(ret['page']))
  end

protected

  # バリデーションエラーを取得する
  # @override
  # @return [nil/GCInvalidRequest] バリデーションエラー結果
  def _invalid
    if ! (@param[:page_id]) 
      return GCInvalidRequest.new 'Parameter page_id required.'
    end
  end

end

# 更新ページ一覧リクエスト用クラス
# @ref https://github.com/growi/growi/blob/master/lib/routes/page.js
# @note notification for 3rd party tool (like Slack)
class GApiRequestPagesUpdatePost < GApiRequestBase

  # コンストラクタ
  # @override
  # @param [Hash] param APIリクエストのパラメータ
  def initialize(param = {})
    super('/_api/pages.updatePost', METHOD_GET, { path: param[:path] })
  end

  # リクエストを実行する
  # @override
  # @param  [String] entry_point APIのエントリーポイントとなるURL（ex. http://localhost:3000/_api/pages.list）
  # @param  [Hash] rest_client_param RestClientのパラメータ
  # @return [Array] リクエスト実行結果
  def execute(entry_point, rest_client_param: {})

    if invalid?
      return validation_msg
    end
    params = { method: :get, url: entry_point, headers: { params: @param } }.merge(rest_client_param)
    GCLogger.logger.debug('Request: ' + params.to_s)

    begin
      raw_ret = RestClient::Request.execute params
      GCLogger.logger.debug('Return: ' + raw_ret.to_s)
      ret = JSON.parse raw_ret
    rescue Exception => e
      GCLogger.logger.error(e)
      return GCInvalidRequest.new "Unknown error occured: #{e}"
    end

    if (!ret['ok'].nil? && ret['ok'] == false)
      return GCInvalidRequest.new "API return false with msg: #{ret['msg']}"
    end

    begin
      posts = []
      ret['updatePost'].each do |post|
        pages.push(GrowiPage.new(post))
      end
      return GApiReturn.new(ok: ret['ok'], data: posts)
    rescue Exception => e
      GCLogger.logger.error(e)
      return GCInvalidRequest.new "Fail to parse: #{e}"
    end
  end

protected

  # バリデーションエラーを取得する
  # @override
  # @return [nil/GCInvalidRequest] バリデーションエラー結果
  def _invalid
    if ! (@param[:path]) 
      return GCInvalidRequest.new 'Parameter path required.'
    end
  end

end

# ページ削除リクエスト用クラス（API利用不可）
# @ref https://github.com/growi/growi/blob/master/lib/routes/page.js
class GApiRequestPagesRemove < GApiRequestBase

  # コンストラクタ
  # @override
  # @param [Hash] param APIリクエストのパラメータ
  def initialize(param = {})
    raise Exception, 'API of pages.remove is forbidden'
    super('/_api/pages.remove', METHOD_GET,
          { page_id: param[:page_id], revision_id: param[:revision_id] })
  end

  # リクエストを実行する
  # @override
  # @param  [String] entry_point APIのエントリーポイントとなるURL（ex. http://localhost:3000/_api/pages.list）
  # @param  [Hash] rest_client_param RestClientのパラメータ
  # @return [Array] リクエスト実行結果
  def execute(entry_point, rest_client_param: {})

    if invalid?
      return validation_msg
    end

    param = { method: :get, url: entry_point, headers: { params: @param } }.merge(rest_client_param)
    GCLogger.logger.debug('Request: ' + params.to_s)

    begin
      raw_ret = RestClient::Request.execute params
      GCLogger.logger.debug('Return: ' + raw_ret.to_s)
      ret = JSON.parse raw_ret
    rescue Exception => e
      GCLogger.logger.error(e)
      return GCInvalidRequest.new "Unknown error occured: #{e}"
    end

    if (!ret['ok'].nil? && ret['ok'] == false)
      return GCInvalidRequest.new "API return false with msg: #{ret['msg']}"
    end

    return GApiReturn.new(ok: ret['ok'], data: GrowiPage.new(ret['page']))
  end

protected

  # バリデーションエラーを取得する
  # @override
  # @return [nil/GCInvalidRequest] バリデーションエラー結果
  def _invalid
    if ! (@param[:page_id] || @param[:revision_id]) 
      return GCInvalidRequest.new 'Parameter page_id or revision_id is required.'
    end
  end

end

