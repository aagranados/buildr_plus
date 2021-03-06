#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'buildr_plus/java'

base_directory = File.dirname(Buildr.application.buildfile.to_s)
BuildrPlus::FeatureManager.activate_features([:shared]) if File.exist?("#{base_directory}/shared/src/main/java")
BuildrPlus::FeatureManager.activate_features([:user_experience]) if File.exist?("#{base_directory}/user-experience/src/main/java")
BuildrPlus::FeatureManager.activate_features([:selenium]) if File.exist?("#{base_directory}/selenium-tests/src/test/java")

if BuildrPlus::FeatureManager.activated?(:shared)
  BuildrPlus::Roles.project('shared', :roles => [:shared], :parent => :container, :template => true, :description => 'Shared Components')
end
BuildrPlus::Roles.project('model', :roles => [:model], :parent => :container, :template => true, :description => 'Persistent Entities, Messages and Data Structures')
if BuildrPlus::FeatureManager.activated?(:sync) && !BuildrPlus::Sync.standalone?
  BuildrPlus::Roles.project('sync_model', :roles => [:sync_model], :parent => :container, :template => true, :description => 'Shared Model used to write External synchronization services')
end
BuildrPlus::Roles.project('model-qa-support', :roles => [:model_qa_support], :parent => :container, :template => true, :description => 'Model Test Infrastructure')
BuildrPlus::Roles.project('server', :roles => [:server], :parent => :container, :template => true, :description => 'Server Archive')

if BuildrPlus::FeatureManager.activated?(:gwt)
  BuildrPlus::Roles.project('gwt', :roles => [:gwt], :parent => :container, :template => true, :description => 'GWT Library')
  BuildrPlus::Roles.project('gwt-qa-support', :roles => [:gwt_qa_support], :parent => :container, :template => true, :description => 'GWT Test Infrastructure')

  if BuildrPlus::FeatureManager.activated?(:user_experience)
    BuildrPlus::Roles.project('user-experience', :roles => [:user_experience], :parent => :container, :template => true, :description => 'GWT Client-side UI')
  end
end

if BuildrPlus::FeatureManager.activated?(:soap)
  BuildrPlus::Roles.project('soap-client', :roles => [:soap_client], :parent => :container, :template => true, :description => 'SOAP Client API')
  BuildrPlus::Roles.project('soap-qa-support', :roles => [:soap_qa_support], :parent => :container, :template => true, :description => 'SOAP Test Infrastructure')
end

BuildrPlus::Roles.project('integration-qa-support', :roles => [:integration_qa_support], :parent => :container, :template => true, :description => 'Integration Test Infrastructure')
BuildrPlus::Roles.project('integration-tests', :roles => [:integration_tests], :parent => :container, :template => true, :description => 'Integration Tests')

if BuildrPlus::FeatureManager.activated?(:selenium)
  BuildrPlus::Roles.project('selenium-tests', :roles => [:selenium_tests], :parent => :container, :template => true, :description => 'Selenium Tests')
end

BuildrPlus::ExtensionRegistry.auto_activate!
