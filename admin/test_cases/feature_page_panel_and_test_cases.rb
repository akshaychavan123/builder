ActiveAdmin.register_page "AdHocReport" do
    menu priority: 10, label: "Ad Hoc Report"
  
    content title: "Ad Hoc Report" do
      columns do
        column do
          panel "Total Number of Current Users" do
            para link_to "Total Users: #{AccountBlock::Account.count}", admin_accounts_path
            para link_to "Buyers: #{AccountBlock::Account.where(user_type: 'buyer').count}", admin_accounts_path(q: { user_type_eq: 'buyer' })
            para link_to "Sellers: #{AccountBlock::Account.where(user_type: 'seller').count}", admin_accounts_path(q: { user_type_eq: 'seller' })
          end
  
          panel "Sellers Breakdown" do
            para "Roles:"
            AccountBlock::Account.where(user_type: 'seller').group(:seller_role).count.each do |role, count|
               para link_to "#{role.titleize}: #{count}", admin_accounts_path(q: { seller_role_eq: role }) unless role.nil?
            end
            para "Country / City:"
            AccountBlock::Account.where(user_type: 'seller').group(:country, :city).count.each do |location, count|
              para "#{location[0]} / #{location[1]}: #{count}"
            end
            
            para link_to "Number of sellers with one active listing: #{AccountBlock::Account.count_of_sellers_with_one_active_listing}", admin_accounts_path
            para link_to "Number of sellers with no active listing: #{AccountBlock::Account.with_no_active_listing.count}", admin_accounts_path
            para link_to "Number of sellers with more than one active listing: #{AccountBlock::Account.with_more_than_one_active_listing.count}", admin_accounts_path
          end
  
          panel "Buyers Breakdown" do
            para "Roles:"
          AccountBlock::Account.where(user_type: 'buyer').group(:buyer_role).count.each do |role, count|
            para link_to "#{role.titleize}: #{count}", admin_accounts_path(q: { buyer_role_eq: role }) unless role.nil?
          end
  
            para "Country / City:"
            AccountBlock::Account.where(user_type: 'buyer').group(:country, :city).count.each do |location, count|
              para "#{location[0]} / #{location[1]}: #{count}"
            end
            panel "Number of Acquisitions Closed" do
              (0..2).each do |range|
                range_filter = (range * 5)..(range * 5 + 4)
                count = AccountBlock::Account.where(user_type: 'buyer', number_of_acquisition_closed: range_filter).count
                para "#{range_filter.first}-#{range_filter.last}: #{count}"
              end
            end
  
            panel "Projected Annual Acquisitions" do
              (0..2).each do |range|
                range_filter = (range * 5)..(range * 5 + 4)
                count = AccountBlock::Account.where(user_type: 'buyer', projected_annual_acquisitions: range_filter).count
                para "#{range_filter.first}-#{range_filter.last}: #{count}"
              end
            end
          end
        end
      end
  
      columns do
        column do
          panel "Listings on the Marketplace" do
  
          end
  
          panel "Deleted Listings Breakdown" do
  
          end
  
          panel "Archived Listings Breakdown" do
  
          end
  
          panel "Active Listings Breakdown" do
  
          end
        end
  
        column do
          panel "Closed Deals Breakdown" do
  
          end
  
          panel "Active Deal Discussions Breakdown" do
  
          end
  
          panel "Average Time to Close a Deal" do
  
          end
        end
      end
    end
  end


  =============================================================================================================================

  test cases 




  ===================================================================================================================



  require 'rails_helper'
require 'spec_helper'

RSpec.describe "AdHocReport Page", type: :feature do
  let(:admin_user) { FactoryBot.create(:admin_user) }

  before do
    visit new_admin_user_session_path
    fill_in "Email", with: admin_user.email
    fill_in "Password", with: admin_user.password
    click_button "Login"
  end

  it "displays total number of current users" do
    visit admin_adhocreport_path
    expect(page).to have_content("Total Users:")
    expect(page).to have_content("Buyers:")
    expect(page).to have_content("Sellers:")
  end

  it "displays sellers breakdown" do
    visit admin_adhocreport_path
    expect(page).to have_content("Sellers Breakdown")

  end

  it "displays buyers breakdown" do
    visit admin_adhocreport_path
    expect(page).to have_content("Buyers Breakdown")
  end

  it "displays number of acquisitions closed" do
    visit admin_adhocreport_path
    expect(page).to have_content("Number of Acquisitions Closed")
  end

  it "displays projected annual acquisitions" do
    visit admin_adhocreport_path
    expect(page).to have_content("Projected Annual Acquisitions")
  end

  # it "displays last 10 accounts link" do
  #   visit admin_adhoc_report_path
  #   click_button "Log in" # Attempt to click the login button
  #   expect(page).to have_link("Show Last 10 Accounts", href: admin_accounts_path(q: { s: 'id desc', per_page: 10 }))
  # end
end




=================================================================================================================================================


rails_helper.rb

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper' 
require 'mock_redis'
require_relative '../config/environment'
ENV['RAILS_ENV'] ||= 'test'
#require_relative '../config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
# require 'support/factory_bot'
if ENV['RAILS_ENV'] == 'test'
  require 'simplecov'
  SimpleCov.start 'rails'
  puts "required simplecov"
end
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # You can uncomment this line to turn off ActiveRecord support entirely.
  # config.use_active_record = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, type: :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
  RSpec.configure do |config|
    config.include(Shoulda::Callback::Matchers::ActiveModel)
  end
  
  config.include Devise::Test::ControllerHelpers, :type => :controller
  config.include FactoryBot::Syntax::Methods
end




===================================================================================================================
spec_helper.rb



require 'simplecov'
require 'simplecov-json'
ENV['RAILS_ENV'] ||= 'test'

# SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter

SimpleCov.start('rails')  do
  add_group "Models", "app/models"
  add_group "Controllers", "app/controllers"
  add_group "Admins", "app/admin"
  add_group "Multiple Files", ["app/models", "app/controllers"] # You can also pass in an array
  add_group "bx_blocks", %r{bx_block.*}
  add_filter %r{vendor/ruby/ruby/2.*}
end
# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# See https://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
  #config.include AuthenticationHelper
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  # This option will default to `:apply_to_host_groups` in RSpec 4 (and will
  # have no way to turn it off -- the option exists only for backwards
  # compatibility in RSpec 3). It causes shared context metadata to be
  # inherited by the metadata hash of host groups and examples, rather than
  # triggering implicit auto-inclusion in groups with matching metadata.
  config.shared_context_metadata_behavior = :apply_to_host_groups

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # This allows you to limit a spec run to individual examples or groups
  # you care about by tagging them with `:focus` metadata. When nothing
  # is tagged with `:focus`, all examples get run. RSpec also provides
  # aliases for `it`, `describe`, and `context` that include `:focus`
  # metadata: `fit`, `fdescribe` and `fcontext`, respectively.
  config.filter_run_when_matching :focus

  # Allows RSpec to persist some state between runs in order to support
  # the `--only-failures` and `--next-failure` CLI options. We recommend
  # you configure your source control system to ignore this file.
  config.example_status_persistence_file_path = "spec/examples.txt"

  # Limits the available syntax to the non-monkey patched syntax that is
  # recommended. For more details, see:
  # https://rspec.info/features/3-12/rspec-core/configuration/zero-monkey-patching-mode/
  config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = "doc"
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end








