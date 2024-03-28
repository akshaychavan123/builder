gem 'google-cloud-translate'

you will get creds like below save in initializers/keyfile.json


{
a complete json file 
}


now you have to provide path to access this creds
in developement.rb 
    ENV['GOOGLE_APPLICATION_CREDENTIALS']  =  "config/initializers/keyfile.json"

    or in .env 
    GOOGLE_APPLICATION_CREDENTIALS = config/initializers/keyfile.json

    am adding translation for all the application through the serializer so in base serializer i added below changes 

    require 'google/cloud/translate'

module BuilderBase
  class BaseSerializer
    include FastJsonapi::ObjectSerializer

class << self


  def base_url
    ENV['BASE_URL'] || 'http://localhost:3000'
  end

  def translate_text(value, locale)
    return value unless locale == 'ar'

    begin
      translated_text = Google::Cloud::Translate.new.translate(value.to_s, to: "ar")
      translated_text.text
    rescue Google::Cloud::InvalidArgumentError => e
  
      puts "Google Cloud Translate Error: #{e.message}"
      "#{value} (translation failed)"
    rescue StandardError => e

      puts "Error occurred during translation: #{e.message}"
      "#{value} (translation failed)"
    end
  end


  def translate_attributes(object, locale)
    return object unless locale == "ar"

    excluded_keys = [:file_path, :url] # Add any other keys related to URLs here
    translated_object = object.transform_values do |value|
      if value.is_a?(Hash)
        translate_attributes(value, locale)
      else
         unless excluded_keys.any? { |key| value.to_s.include?(key.to_s) }
            translate_text(value, locale)
         else
            value
         end

      end
    end
    translated_object
  end
end

def serializable_hash(options = {})
  locale = @params[:locale] || 'en' 
  translated_attributes = self.class.translate_attributes(super(), locale)
  translated_attributes
end
  end
end


============================================================================================================================================


in controller in every api have to send this also

    def serialize_options
        {params: {host: request.protocol + request.host_with_port, locale: params[:locale]}}
      end
======================================================================================================================================
translation of the custom errors and messages from google cloud translation  API below file is in concerns 
to use this in application controller add 

    include Localizable


require 'google/cloud/translate'

module Localizable
  extend ActiveSupport::Concern

  included do
    before_action :set_locale, if: -> { params[:locale] == 'ar' }
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
    I18n.locale = :ar if params[:locale] == 'ar'
  end

  def render(options = nil, extra_options = {}, &block)
    if params[:locale] == 'ar' && options && options[:json]
      options[:json] = translate_json(options[:json])
    end
    super(options, extra_options, &block)
  end

  def translate_json(json)
    translate_hash(json)
  end

  def translate_hash(hash)
    hash.transform_values do |value|
      if value.is_a?(Hash)
        translate_hash(value)
      elsif value.is_a?(Array)
        value.map { |v| v.is_a?(Hash) ? translate_hash(v) : translate_value(v) }
      else
        translate_value(value)
      end
    end
  end

  def translate_value(value)
    translate_text(value, 'ar') || value
  end

  def translate_text(text, locale)
    translate = Google::Cloud::Translate.new
    translation = translate.translate(text, to: locale)
    translation.text
  rescue StandardError => e
    "#{text} (translation failed: #{e.message})"
  end

  def not_found
    render json: { error: 'record_not_found' }, status: :not_found
  end
end

=====================================================================================================================

translation of custom errors and message s through i18n 


====================================================================================================================

in concerns localizable.rb
    add in application controller 
include Localizable

in localizable.rb file 

    module Localizable
        extend ActiveSupport::Concern
      
        included do
          before_action :set_locale, if: -> { params[:locale] == 'ar' }
          rescue_from ActiveRecord::RecordNotFound, with: :not_found
        end
      
        def set_locale
          I18n.locale = params[:locale] || I18n.default_locale
          I18n.locale = :ar if params[:locale] == 'ar'
        end
      
        def render(options = nil, extra_options = {}, &block)
          if params[:locale] == 'ar' && options && options[:json]
            translate_common_messages(options[:json])
          end
          super(options, extra_options, &block)
        end
      
        def translate_common_messages(json)
          if json[:error]
            json[:error] = I18n.t("common.errors.#{json[:error]}")
          elsif json[:message]
            json[:message] = I18n.t("common.success_messages.#{json[:message]}")
          elsif json[:meta]
            json[:meta] = translate_meta(json[:meta])
          end
        end
      
        def translate_meta(meta)
          meta.transform_values do |value|
            if meta.has_key?(:message)
              translated_value ||= I18n.t("common.success_messages.#{value}") 
              translated_value ||= value
            else
              value
            end
          end
        end
      
        def not_found
          render json: { error: 'record_not_found' }, status: :not_found
        end
      end
      