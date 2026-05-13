import { stepComponentRegistry } from "./stepComponentRegistry"
import { fetchInternalAPIService } from "../utilities/fetchInternalAPIService"

const unknownStep = (step) =>
  `<p class="usa-error-message" role="alert">Unsupported component type: ${step.component_type}</p>`

const toErrorsByField = (errors = []) =>
  errors.reduce((acc, error) => {
    if (error?.field && error?.message) {
      acc[error.field] = error.message
    }
    return acc
  }, {})

const toErrorSummary = (errorsByField = {}) => {
  const keys = Object.keys(errorsByField)
  if (!keys.length) {
    return ""
  }

  const items = keys
    .map(
      (field) => `
      <li>
        <a href="#${field}">${errorsByField[field]}</a>
      </li>
    `,
    )
    .join("")

  return `
    <div
      class="usa-error-summary"
      role="alert"
      tabindex="-1"
      aria-labelledby="applicant-step-error-summary-title"
      data-testid="error-summary"
    >
      <h2
        class="usa-error-summary__title"
        id="applicant-step-error-summary-title"
      >
        There is a problem
      </h2>
      <div class="usa-error-summary__body">
        <ul class="usa-list usa-error-summary__list">${items}</ul>
      </div>
    </div>
  `
}

export const renderServerDefinedSteps = ({
  steps = [],
  values = {},
  errorsByField = {},
}) => {
  const formBody = steps
    .map((step) => {
      const component = stepComponentRegistry[step.component_type]
      if (!component) {
        return unknownStep(step)
      }

      return component({ step, value: values[step.id], errorsByField })
    })
    .join("")

  return `${toErrorSummary(errorsByField)}${formBody}`
}

export class ApplicantStepFlow {
  constructor({ formElement, saveEndpoint, steps = [] }) {
    this.formElement = formElement
    this.saveEndpoint = saveEndpoint
    this.steps = steps
    this.errorsByField = {}
    this.pending = false
  }

  render(values = {}) {
    this.formElement.innerHTML = renderServerDefinedSteps({
      steps: this.steps,
      values,
      errorsByField: this.errorsByField,
    })

    const summary = this.formElement.querySelector("[data-testid='error-summary']")
    if (summary) {
      summary.focus()
    }
  }

  collectValues() {
    const values = {}

    this.steps.forEach((step) => {
      const input = this.formElement.querySelector(`#${step.id}`)
      if (!input) {
        return
      }

      if (input.type === "checkbox") {
        values[step.id] = input.checked
        return
      }

      values[step.id] = input.value
    })

    return values
  }

  async saveAndContinue() {
    if (this.pending) {
      return { skipped: true }
    }

    const optimisticValues = this.collectValues()
    this.pending = true
    this.formElement.setAttribute("aria-busy", "true")

    const response = await fetchInternalAPIService(this.saveEndpoint, {
      method: "POST",
      body: JSON.stringify({ values: optimisticValues }),
    })

    this.pending = false
    this.formElement.removeAttribute("aria-busy")

    if (response?.errors?.length) {
      this.errorsByField = toErrorsByField(response.errors)
      this.render(optimisticValues)
      return { ok: false, errorsByField: this.errorsByField }
    }

    this.errorsByField = {}
    this.render(response.values || optimisticValues)
    return { ok: true, next_path: response.next_path }
  }
}
