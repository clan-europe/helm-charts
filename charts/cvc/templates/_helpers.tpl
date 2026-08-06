{{- /* All common helpers provided by the common library chart. */ -}}

{{/*
Returns the effective credentials secret name:
uses existingSecret when set, otherwise secretName.
*/}}
{{- define "cvc.credentialsSecretName" -}}
{{- $c := .Values.credentials | default dict -}}
{{- if $c.existingSecret -}}
{{- $c.existingSecret -}}
{{- else -}}
{{- $c.secretName | default "cvc-credentials" -}}
{{- end -}}
{{- end }}
