import { ref, computed } from 'vue'
import { supabase } from '../lib/supabase'

// State global (di-share ke seluruh komponen karena didefinisikan di luar function)
const session = ref(null)
const profile = ref(null)
const loading = ref(true)
const initialized = ref(false)

async function loadProfile(userId) {
  if (!userId) {
    profile.value = null
    return
  }
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .single()

  if (error) {
    console.error('Gagal memuat profil:', error.message)
    profile.value = null
    return
  }
  profile.value = data
}

async function init() {
  if (initialized.value) return
  initialized.value = true

  const { data } = await supabase.auth.getSession()
  session.value = data.session
  if (session.value?.user) {
    await loadProfile(session.value.user.id)
  }
  loading.value = false

  supabase.auth.onAuthStateChange(async (_event, newSession) => {
    session.value = newSession
    if (newSession?.user) {
      await loadProfile(newSession.user.id)
    } else {
      profile.value = null
    }
  })
}

async function signUp({ email, password, fullName, phone }) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName,
        phone: phone
      }
    }
  })
  if (error) throw error

  // Buat baris profil (juga dijaga oleh trigger di database sebagai fallback)
  if (data.user) {
    await supabase.from('profiles').upsert({
      id: data.user.id,
      full_name: fullName,
      phone: phone,
      role: 'member'
    })
  }
  return data
}

async function signIn({ email, password }) {
  const { data, error } = await supabase.auth.signInWithPassword({ email, password })
  if (error) throw error
  session.value = data.session
  if (data.user) await loadProfile(data.user.id)
  return data
}

async function signOut() {
  await supabase.auth.signOut()
  session.value = null
  profile.value = null
}

export function useAuth() {
  return {
    session,
    profile,
    loading,
    isLoggedIn: computed(() => !!session.value),
    isAdmin: computed(() => profile.value?.role === 'admin'),
    init,
    signUp,
    signIn,
    signOut
  }
}
