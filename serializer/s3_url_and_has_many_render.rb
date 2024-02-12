# app/serializers/company_profile_serializer.rb
class CompanyProfileSerializer < ActiveModel::Serializer
    attributes :id, :logo_url, :company_name, :contact_number, :social_links, :emails, :newsletter_email, :company_details, :created_at, :updated_at
  
    def company_details
      object.company_details.map do |company_detail|
        {
          id: company_detail.id,
          phone: company_detail.phone,
          email: company_detail.email,
          address: company_detail.address,
          country: company_detail.country,
          state: company_detail.state,
          city: company_detail.city,
          pin: company_detail.pin,
          incorporation_date: company_detail.incorporation_date,
          pan_number: company_detail.pan_number,
          gst_number: company_detail.gst_number,
          tan_number: company_detail.tan_number,
          images_url: company_detail.images.map { |image| s3_url(image) }
        }.transform_values { |value| value.present? ? value : nil }
      end
    end

    def logo_url
        s3_url(object.logo) if object.logo.attached?
      end
  
    private
  
    def s3_url(attachment)
      return nil if attachment.nil? || attachment.url.nil?
      url_parts = attachment.url.split('?', 2)
      base_url = url_parts.first
      base_url
    end
  end

  to take specified fields from the assiciative model
  suppose post belong to user and we want some user data in post serializer 

  attributes :id, :title , :likes , :user_data

  attribute :user_data do |object|
    {
      id: object.user.id,
      email: object.user.email,
      define required fields like more
    }
  end