const escapeHtml = (value = "") =>
  String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")

const errorMessage = (id, errorsByField = {}) => errorsByField[id] || ""

const renderFieldError = (id, errorsByField = {}) => {
  const message = errorMessage(id, errorsByField)
  if (!message) {
    return ""
  }

  return `
    <p
      class="usa-error-message"
      id="${id}-error"
      role="alert"
    >
      ${escapeHtml(message)}
    </p>
  `
}

const inputErrorAttributes = (id, errorsByField = {}) => {
  if (!errorMessage(id, errorsByField)) {
    return ""
  }

  return `aria-invalid="true" aria-describedby="${id}-error"`
}

const renderTextInput = ({ step, value = "", errorsByField = {} }) => `
  <div class="usa-form-group ${errorMessage(step.id, errorsByField) ? "usa-form-group--error" : ""}">
    <label
      class="usa-label"
      for="${step.id}"
    >
      ${escapeHtml(step.label || "")}
    </label>
    ${renderFieldError(step.id, errorsByField)}
    <input
      class="usa-input"
      id="${step.id}"
      name="${step.id}"
      type="text"
      value="${escapeHtml(value)}"
      ${inputErrorAttributes(step.id, errorsByField)}
    />
  </div>
`

const renderDateInput = ({ step, value = "", errorsByField = {} }) => `
  <div class="usa-form-group ${errorMessage(step.id, errorsByField) ? "usa-form-group--error" : ""}">
    <label
      class="usa-label"
      for="${step.id}"
    >
      ${escapeHtml(step.label || "")}
    </label>
    ${renderFieldError(step.id, errorsByField)}
    <input
      class="usa-input"
      id="${step.id}"
      name="${step.id}"
      type="date"
      value="${escapeHtml(value)}"
      ${inputErrorAttributes(step.id, errorsByField)}
    />
  </div>
`

const renderAttestationCheckbox = ({ step, value = false, errorsByField = {} }) => `
  <div class="usa-form-group ${errorMessage(step.id, errorsByField) ? "usa-form-group--error" : ""}">
    <fieldset class="usa-fieldset">
      <legend class="usa-legend">
        ${escapeHtml(step.label || "")}
      </legend>
      ${renderFieldError(step.id, errorsByField)}
      <div class="usa-checkbox">
        <input
          class="usa-checkbox__input"
          id="${step.id}"
          name="${step.id}"
          type="checkbox"
          value="true"
          ${value ? "checked" : ""}
          ${inputErrorAttributes(step.id, errorsByField)}
        />
        <label
          class="usa-checkbox__label"
          for="${step.id}"
        >
          ${escapeHtml(step.checkbox_label || "I attest this is true")}
        </label>
      </div>
    </fieldset>
  </div>
`

const renderDocumentUpload = ({ step, errorsByField = {} }) => `
  <div class="usa-form-group ${errorMessage(step.id, errorsByField) ? "usa-form-group--error" : ""}">
    <label
      class="usa-label"
      for="${step.id}"
    >
      ${escapeHtml(step.label || "")}
    </label>
    ${renderFieldError(step.id, errorsByField)}
    <input
      class="usa-file-input"
      id="${step.id}"
      name="${step.id}"
      type="file"
      ${inputErrorAttributes(step.id, errorsByField)}
    />
  </div>
`

export const stepComponentRegistry = {
  attestation_checkbox: renderAttestationCheckbox,
  text_input: renderTextInput,
  date_input: renderDateInput,
  document_upload: renderDocumentUpload,
}
