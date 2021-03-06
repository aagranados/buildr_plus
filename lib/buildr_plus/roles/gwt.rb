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

BuildrPlus::Roles.role(:gwt) do
  BuildrPlus::FeatureManager.ensure_activated(:gwt)

  if BuildrPlus::FeatureManager.activated?(:domgen)
    generators = [:gwt, :gwt_rpc_shared, :gwt_rpc_client_service, :gwt_client_jso, :imit_shared, :imit_client_service, :imit_client_entity]
    Domgen::Build.define_generate_task(generators, :buildr_project => project) do |t|
      t.filter = Proc.new do |artifact_type, artifact|
        artifact_type != :message || !artifact.any_non_standard_types?
      end if BuildrPlus::FeatureManager.activated?(:user_experience)
    end
  end

  compile.with BuildrPlus::Libs.findbugs_provided,
               BuildrPlus::Libs.replicant_client

  BuildrPlus::Roles.merge_projects_with_role(project.compile, :shared)

  test.with BuildrPlus::Libs.mockito

  package(:jar)
  package(:sources)

  BuildrPlus::Gwt.add_source_to_jar(project)

  # This compile exists to verify that module is independently compilable
  BuildrPlus::Gwt.define_gwt_task(project)

  BuildrPlus::Gwt.define_gwt_idea_facet(project)

  p = project.root_project

  check package(:jar), 'should contain generated source files' do
    it.should contain("#{p.group.gsub('.', '/')}/shared/net/#{BuildrPlus::Naming.pascal_case(p.name)}ReplicationGraph.class")
    it.should contain("#{p.group.gsub('.', '/')}/shared/net/#{BuildrPlus::Naming.pascal_case(p.name)}ReplicationGraph.java")
  end
end
