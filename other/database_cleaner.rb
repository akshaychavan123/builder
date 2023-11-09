# gemfile

group :test do
    gem 'database_cleaner'
  end



require 'spec_helper'
+require 'support/database_cleaner.rb'
 ENV['RAILS_ENV'] ||= 'test'
 require_relative '../config/environment'
 # Prevent database truncation if the environment is production
diff --git a/template-app/spec/support/database_cleaner.rb b/template-app/spec/support/database_cleaner.rb
new file mode 100644
index 00000000..698f6880
--- /dev/null
+++ b/template-app/spec/support/database_cleaner.rb
@@ -0,0 +1,18 @@
+require 'database_cleaner'
+
+DatabaseCleaner.strategy = :truncation
+
+RSpec.configure do |config|
+  config.before(:suite) do
+    DatabaseCleaner.strategy = :transaction
+    DatabaseCleaner.clean_with(:truncation)
+  end
+
+  config.before(:each) do
+    DatabaseCleaner.start
+  end
+
+  config.after(:each) do
+    DatabaseCleaner.clean
+  end
+end
(END)
