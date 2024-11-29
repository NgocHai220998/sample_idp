import * as webauthn from "@github/webauthn-json/browser-ponyfill";

const csrfMetaTag = document.querySelector('meta[name="csrf-token"]');
const csrfToken = csrfMetaTag.content;

const isConditionalMediationAvailable = async () => {
  if (PublicKeyCredential.isConditionalMediationAvailable) {
    return await PublicKeyCredential.isConditionalMediationAvailable();
  }
  return false;
}

const isConditionalCreationAvailable = async () => {
  if (
    PublicKeyCredential &&
    (PublicKeyCredential).getClientCapabilities
  ) {
    const capability = await (
      PublicKeyCredential
    ).getClientCapabilities();
    return !!capability.conditionalCreate;
  }

  return false;
};

const deviceSupported = async () => {
  if (webauthn.supported() && (await isConditionalMediationAvailable())) {
    Cookies.set('icma', 'true');

    return true;
  } else {
    Cookies.remove('icma');

    return false;
  }
};

const autoUpgradePasskeySupported = async () => {
  if (webauthn.supported() && (await isConditionalCreationAvailable())) {
    Cookies.set('icca', 'true');

    return true;
  } else {
    Cookies.remove('icca');

    return false;
  }
};

// ---------------------------- Registration ----------------------------

async function getOptions() {
  const response = await fetch("/webauthn/credentials/options", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken,
    },
  });

  if (response.ok) {
    return response.json();
  } else {
    throw new Error(`Request failed with status ${response.status}`);
  }
}

async function sentRegistrationData(credential, redirectUrl = "/webauthn/credentials") {
  try {
    const response = await fetch("/webauthn/credentials", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
      },
      body: JSON.stringify(credential),
    });

    if (response.ok) {
      await response.json();
      window.location.href = redirectUrl;
    } else {
      console.log(`Request failed with status ${response.status}`);
    }
  } catch (error) {
    console.error("Error:", error);
  }
}

// ---------------------------- Assertion (Authentication) ----------------------------

async function getAssertionOptions() {
  const response = await fetch('/webauthn/assertion/options', {
      method: 'POST',
      headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
      },
  });

  if(response.ok) {
      return response.json();
  } else {
      throw new Error(`Request failed with status ${response.status}`);
  }
}

const postWebauthnAssertion = async (authenticatorResponse) => {
  const response = await fetch('/webauthn/assertion', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken
    },
    body: JSON.stringify({
      authenticatorResponse: authenticatorResponse
    })
  });

  if(response.ok || response.status == 401) {
    return await response.json();
  } else {
    throw new Error(`Request failed with status ${response.status}`);
  }
}

const getAuthenticatorResponse = async (options) => {
  if (!options) {
    throw new Error(
      'Options cannot be empty upon ' +
        'calling credentials.get().' +
        ' Call canSignInWithWebauthn first.',
    );
  }

  const response = await webauthn.get(options);
  return response;
};


// ---------------------------- Automatic Passkey Upgrades ----------------------------

const postWebauthnCredentialsForAutomaticPasskeyUpgrades = async () => {
  const options = await getOptions();
  const CreateOptions = webauthn.parseCreationOptionsFromJSON(options)
  CreateOptions.mediation = "conditional"; // https://w3c.github.io/webappsec-credential-management/#dom-credentialmediationrequirement-conditional
  
  const credential = await webauthn.create(CreateOptions);

  const credentialData = {
    ...credential.toJSON(),
  };

  sentRegistrationData(credentialData, "/");
};

const performAutomaticPasskeyUpgrades = async () => {
  if (await isConditionalCreationAvailable()) {
    return await postWebauthnCredentialsForAutomaticPasskeyUpgrades();
  }
  throw new Error('conditionalCreation not available');
}

deviceSupported();
autoUpgradePasskeySupported();

const WebauthnObject = {
  webauthn, 
  isConditionalMediationAvailable,
  isConditionalCreationAvailable,
  deviceSupported,
  autoUpgradePasskeySupported,
  // Registration methods
  getOptions,
  sentRegistrationData,
  // Assertion (Authentication) methods
  getAssertionOptions,
  postWebauthnAssertion,
  getAuthenticatorResponse,
  // Automatic Passkey Upgrades
  performAutomaticPasskeyUpgrades
}

window.WebauthnObject = WebauthnObject;
