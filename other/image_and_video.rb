model===============
has_many_attached :media, dependent: :destroy
    has_many_attached :images, dependent: :destroy
    has_many :likes, class_name: 'BxBlockLike::Like', as: :likeable, dependent: :destroy

    validates_presence_of :body
    validates :media,
              size: { between: 1..3.megabytes }, content_type: IMAGE_CONTENT_TYPES


controller ============
params.permit(
        :name, :description, :body, :location, :title, :item, :quantity, :quotation_last_date,
        tag_list: [],
        images: []
        )

        PostSerializer.new(posts, serialization_options).serializable_hash


        def serialization_options
            { params: { host: request.protocol + request.host_with_port } }
          end


serializer===========================

attribute :images_and_videos do |object, params|
    host = params[:host] || ""
    object.images.attached? ?
      object.images.map { |image|
        {
          id: image.id,
          url: host + Rails.application.routes.url_helpers.rails_blob_url(
            image, only_path: true,
          type: image.blob.content_type.split('/')[0]
          )
        }
      } : []
  end

  attribute :media do |object, params|
    host = params[:host] || ""
    object.media.attached? ?
      object.media.map { |media|
        {
          id: media.id,
          url: host + Rails.application.routes.url_helpers.rails_blob_url(
            media, only_path: true,
          ),
          filename: media.blob[:filename],
          content_type: media.blob[:content_type],
        }
      } : []
  end
