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

BuildrPlus::Dbt.library = true
BuildrPlus::Artifacts.library = true
BuildrPlus::Artifacts.war = false

base_directory = File.dirname(Buildr.application.buildfile.to_s)
BuildrPlus::FeatureManager.activate_features([:gwt]) if File.exist?("#{base_directory}/gwt")
BuildrPlus::FeatureManager.activate_features([:shared]) if File.exist?("#{base_directory}/shared/src/main/java")
BuildrPlus::FeatureManager.activate_features([:replicant]) if BuildrPlus::FeatureManager.activated?(:gwt)

if BuildrPlus::FeatureManager.activated?(:shared)
  BuildrPlus::Roles.project('shared', :roles => [:shared], :parent => :container, :template => true, :description => 'Shared Components')
end
BuildrPlus::Roles.project('model', :roles => [:model], :parent => :container, :template => true, :description => 'Persistent Entities, Messages and Data Structures')
BuildrPlus::Roles.project('model-qa-support', :roles => [:model_qa_support], :parent => :container, :template => true, :description => 'Model Test Infrastructure')
if File.exist?("#{base_directory}/server")
  BuildrPlus::Roles.project('server', :roles => [:library], :parent => :container, :template => true, :description => 'Library Archive')
end

if BuildrPlus::FeatureManager.activated?(:gwt)
  BuildrPlus::Roles.project('gwt', :roles => [:gwt], :parent => :container, :template => true, :description => 'GWT Library')
  BuildrPlus::Roles.project('gwt-qa-support', :roles => [:gwt_qa_support], :parent => :container, :template => true, :description => 'GWT Test Infrastructure')
end

BuildrPlus::Roles.default_role = :container
BuildrPlus::ExtensionRegistry.auto_activate!