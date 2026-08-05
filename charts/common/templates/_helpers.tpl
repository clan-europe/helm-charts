{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "common.labels" -}}
helm.sh/chart: {{ include "common.chart" . }}
{{ include "common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Secret name: use existingSecret when supplied, else the chart-managed secret.
*/}}
{{- define "common.secretName" -}}
{{- if (.Values.secrets).existingSecret -}}
{{- .Values.secrets.existingSecret -}}
{{- else -}}
{{- include "common.fullname" . -}}
{{- end -}}
{{- end }}

{{/*
Returns true (non-empty) when the chart should mount secrets via envFrom.
True when either existingSecret is set OR any secrets key is non-empty.
*/}}
{{- define "common.hasSecrets" -}}
{{- $s := .Values.secrets | default dict -}}
{{- if $s.existingSecret -}}
true
{{- else if or $s.DISCORD_TOKEN $s.POCKETBASE_PASSWORD $s.R2_ACCESS_KEY_ID $s.R2_ACCESS_KEY_SECRET -}}
true
{{- end -}}
{{- end }}

{{/*
Returns true (non-empty) when the chart should mount config via envFrom.
True when .Values.config has at least one non-empty value.
*/}}
{{- define "common.hasConfig" -}}
{{- $found := "" -}}
{{- range $k, $v := (.Values.config | default dict) -}}
{{- if $v -}}{{- $found = "true" -}}{{- end -}}
{{- end -}}
{{- $found -}}
{{- end }}
