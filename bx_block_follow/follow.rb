def create
    followable_id = params[:account_id]
    follow = Follow.find_by(follower_id: current_user.id, followed_account_id: followable_id)
    return render json: {errors: [
      {message: 'You already follow.'},
    ]}, status: :unprocessable_entity if follow.present?
    account = AccountBlock::Account.find_by(id: followable_id)
    return render json: {errors: [
      {message: 'User does not exist.'},
    ]}, status: :unprocessable_entity unless account
    return render json: {errors: [
      {message: 'You cannot follow yourself.'},
    ]}, status: :unprocessable_entity if current_user.id.to_i == followable_id.to_i
    follow = BxBlockFollowers::Follow.new(follower_id: current_user.id, followed_account_id: followable_id)
    if follow.save
      render json: FollowSerializer.new(follow, meta: {
        message: "Successfully followed."}).serializable_hash, status: :created
    else
      render json: {errors: format_activerecord_errors(follow.errors)},
             status: :unprocessable_entity
    end
  end






  module BxBlockFollowers
    class Follow < BxBlockFollowers::ApplicationRecord
      self.table_name = :bx_block_followers_follows
      # validates :account_id, presence: true #, allow_blank: false
      # validates :current_user_id, presence: true
      belongs_to :follower, foreign_key: :follower_id, class_name: "AccountBlock::Account"
      belongs_to :followed_account, foreign_key: :followed_account_id, class_name: "AccountBlock::Account"
  
      # def self.policy_class
      #   FollowerPolicy
      # end
    end
  end

  

  class RemoveIndexFromFollow < ActiveRecord::Migration[6.0]
    def change
      remove_index :follows, name: "index_bx_block_followers_follows_on_account_id"
    end
  end
  

  class AddColoumnToFollows < ActiveRecord::Migration[6.0]
    def change
      add_column :bx_block_followers_follows, :follower_id, :integer
      add_column :bx_block_followers_follows, :followed_account_id, :integer
    end
  end
  

  namespace :bx_block_followers do
    post "create", to: "follows#create"
  end
