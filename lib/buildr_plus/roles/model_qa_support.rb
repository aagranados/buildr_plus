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

BuildrPlus::Roles.role(:model_qa_support) do
  if BuildrPlus::FeatureManager.activated?(:domgen)
    generators = []
    generators << [:jpa_main_qa, :jpa_main_qa_external] if BuildrPlus::FeatureManager.activated?(:db)
    generators << [:ejb_main_qa_external] if BuildrPlus::FeatureManager.activated?(:ejb)

    Domgen::Build.define_generate_task(generators.flatten, :buildr_project => project)
  end

  project.publish = true

  compile.with BuildrPlus::Libs.guiceyloops

  BuildrPlus::Roles.merge_projects_with_role(project.compile, :model)

  package(:jar)
  package(:sources)
end
