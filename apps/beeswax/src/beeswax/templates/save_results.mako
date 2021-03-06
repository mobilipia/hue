## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
from desktop.views import commonheader, commonfooter
from django.utils.translation import ugettext as _
%>
<%namespace name="layout" file="layout.mako" />
<%namespace name="comps" file="beeswax_components.mako" />
<%namespace name="util" file="util.mako" />
${commonheader(_('Create table from file'), app_name, user, '100px')}
${layout.menubar(section='history')}
<div class="container-fluid">
% if error_msg:
<h4>${error_msg}</h4>
% endif
  <h1>${_('Save Query Results')}</h1>

  <form id="saveForm" action="${action}" method="POST" class="form form-inline">
    <fieldset>
      <div class="control-group">
        <div class="controls">
          <label class="radio">
            <input id="id_save_target_0" type="radio" name="save_target" value="to a new table" checked="checked"/>
            &nbsp;${_('In a new table')}
          </label>
          ${comps.field(form['target_table'], notitle=True, placeholder="Table Name")}
        </div>
      </div>
      <div class="control-group">
        <div class="controls">
          <label class="radio">
            <input id="id_save_target_1" type="radio" name="save_target" value="to HDFS directory">
            &nbsp;${_('In an HDFS directory')}
          </label>
          ${comps.field(form['target_dir'], notitle=True, hidden=True, placeholder=_('Results location'), klass="pathChooser")}
        </div>
      </div>
      <div id="fileChooserModal" class="smallModal well hide">
        <a href="#" class="close" data-dismiss="modal">&times;</a>
      </div>
    </fieldset>
    <div class="form-actions">
      <input type="submit" name="save" value="${_('Save')}" class="btn btn-primary"/>
      <input type="submit" name="cancel" value="${_('Cancel')}" class="btn"/>
    </div>
  </form>
</div>


<script type="text/javascript" charset="utf-8">
  $(document).ready(function () {
    $("input[name='save_target']").change(function () {
      $(".errorlist").addClass("hide");
      $(".control-group.error").removeClass("error");
      $("input[name='target_table']").removeClass("fieldError");
      if ($(this).val().indexOf("HDFS") > -1) {
        $("input[name='target_table']").addClass("hide").val("");
        $("input[name='target_dir']").removeClass("hide");
        $(".fileChooserBtn").removeClass("hide");
      }
      else {
        $("input[name='target_table']").removeClass("hide");
        $("input[name='target_dir']").addClass("hide");
        $(".fileChooserBtn").addClass("hide");
      }
    });

    $("input[name='save_target']").change();

    $("#saveForm").submit(function (e) {
      if ($("input[name='save_target']:checked").val().indexOf("HDFS") > -1) {
        if ($.trim($("input[name='target_dir']").val()) == "") {
          $("input[name='target_dir']").parents(".control-group").addClass("error");
          $("input[name='target_dir']").parents(".control-group").find(".fileChooserBtn").addClass("btn-danger");
          return false;
        }
      }
      else {
        if ($.trim($("input[name='target_table']").val()) == "") {
          $("input[name='target_table']").parents(".control-group").addClass("error");
          return false;
        }
      }
      return true;
    });

    $("input[name='target_dir']").after(getFileBrowseButton($("input[name='target_dir']")));

    function getFileBrowseButton(inputElement) {
      return $("<a>").addClass("btn").addClass("fileChooserBtn").addClass("hide").text("..").click(function (e) {
        e.preventDefault();
        $("#fileChooserModal").jHueFileChooser({
          onFolderChange:function (filePath) {
            inputElement.val(filePath);
          },
          onFolderChoose:function (filePath) {
            inputElement.val(filePath);
            $("#fileChooserModal").slideUp();
          },
          createFolder:false,
          uploadFile:false,
          selectFolder:true,
          initialPath:$.trim(inputElement.val())
        });
        $("#fileChooserModal").slideDown();
        $("input[name='target_dir']").parents(".control-group").removeClass("error");
        $("input[name='target_dir']").parents(".control-group").find(".fileChooserBtn").removeClass("btn-danger");
      });
    }
  });
</script>
${commonfooter(messages)}
