import { describe, expect, it, vi, beforeEach } from "vitest"
import { ApplicantStepFlow, renderServerDefinedSteps } from "../../../app/javascript/applicant_frontend/applicantStepFlow"

vi.mock("../../../app/javascript/utilities/fetchInternalAPIService", () => ({
  fetchInternalAPIService: vi.fn(),
}))

import { fetchInternalAPIService } from "../../../app/javascript/utilities/fetchInternalAPIService"

const steps = [
  { id: "first_name", component_type: "text_input", label: "First name" },
  { id: "date_of_birth", component_type: "date_input", label: "Date of birth" },
  { id: "attestation", component_type: "attestation_checkbox", label: "Attestation" },
  { id: "verification_doc", component_type: "document_upload", label: "Upload a paystub" },
]

describe("renderServerDefinedSteps", () => {
  it("renders components using the component_type registry and includes shared accessibility patterns", () => {
    const html = renderServerDefinedSteps({ steps, values: { first_name: "Ada" } })

    expect(html).toContain('type="text"')
    expect(html).toContain('type="date"')
    expect(html).toContain('type="checkbox"')
    expect(html).toContain('type="file"')
    expect(html).not.toContain("data-testid=\"error-summary\"")
  })
})

describe("ApplicantStepFlow", () => {
  beforeEach(() => {
    document.body.innerHTML = "<form id='step-form'></form>"
    vi.clearAllMocks()
  })

  it("shows field-level validation and error summary when backend returns errors", async () => {
    fetchInternalAPIService.mockResolvedValue({
      errors: [{ field: "first_name", message: "First name is required" }],
    })

    const form = document.getElementById("step-form")
    const flow = new ApplicantStepFlow({ formElement: form, saveEndpoint: "/save", steps })
    flow.render({})

    await flow.saveAndContinue()

    expect(form.innerHTML).toContain("data-testid=\"error-summary\"")
    expect(form.innerHTML).toContain("First name is required")
    expect(form.querySelector("#first_name").getAttribute("aria-invalid")).toBe("true")
  })

  it("supports optimistic save-and-continue behavior", async () => {
    fetchInternalAPIService.mockResolvedValue({ values: { first_name: "Ada" }, next_path: "/next" })

    const form = document.getElementById("step-form")
    const flow = new ApplicantStepFlow({ formElement: form, saveEndpoint: "/save", steps })
    flow.render({ first_name: "Ada" })

    const result = await flow.saveAndContinue()

    expect(result).toEqual({ ok: true, next_path: "/next" })
    expect(fetchInternalAPIService).toHaveBeenCalledWith(
      "/save",
      expect.objectContaining({ method: "POST" }),
    )
    expect(form.getAttribute("aria-busy")).toBe(null)
  })
})
