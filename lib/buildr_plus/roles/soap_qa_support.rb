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

BuildrPlus::Roles.role(:soap_qa_support) do
  BuildrPlus::FeatureManager.ensure_activated(:soap)

  if BuildrPlus::FeatureManager.activated?(:domgen)
    Domgen::Build.define_generate_task([:ee_data_types, :ee_exceptions, :jws_fake_server], :buildr_project => project)
  end

  project.publish = true

  compile.with BuildrPlus::Libs.ee_provided,
               BuildrPlus::Libs.glassfish_embedded,
               BuildrPlus::Libs.mockito

  if BuildrPlus::FeatureManager.activated?(:gwt)
    compile.with BuildrPlus::Libs.jackson_gwt_support, BuildrPlus::Libs.gwt_datatypes
  end

  BuildrPlus::Roles.merge_projects_with_role(project.compile, :soap_client)

  package(:jar)
  package(:sources)
end
