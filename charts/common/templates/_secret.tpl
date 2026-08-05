{{- define "common.secret" -}}
{{- $s := .Values.secrets | default dict -}}
{{- if not $s.existingSecret -}}
{{- if include "common.hasSecrets" . -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "common.fullname" . }}
  labels:
    {{- include "common.labels" . | nindent 4 }}
type: Opaque
stringData:
  {{- with $s.DISCORD_TOKEN }}
  DISCORD_TOKEN: {{ . | quote }}
  {{- end }}
  {{- with $s.POCKETBASE_PASSWORD }}
  POCKETBASE_PASSWORD: {{ . | quote }}
  {{- end }}
  {{- with $s.R2_ACCESS_KEY_ID }}
  R2_ACCESS_KEY_ID: {{ . | quote }}
  {{- end }}
  {{- with $s.R2_ACCESS_KEY_SECRET }}
  R2_ACCESS_KEY_SECRET: {{ . | quote }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}
