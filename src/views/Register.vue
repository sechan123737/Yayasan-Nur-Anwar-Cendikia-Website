<script setup>
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuth } from '../composables/useAuth'

const fullName = ref('')
const phone = ref('')
const email = ref('')
const password = ref('')
const errorMsg = ref('')
const submitting = ref(false)
const done = ref(false)

const router = useRouter()
const route = useRoute()
const { signUp } = useAuth()

async function handleSubmit() {
  errorMsg.value = ''
  if (password.value.length < 6) {
    errorMsg.value = 'Kata sandi minimal 6 karakter.'
    return
  }
  submitting.value = true
  try {
    const data = await signUp({
      email: email.value,
      password: password.value,
      fullName: fullName.value,
      phone: phone.value
    })
    // Jika project Supabase mewajibkan konfirmasi email, session belum ada di sini.
    if (data.session) {
      router.push(route.query.redirect || '/')
    } else {
      done.value = true
    }
  } catch (err) {
    errorMsg.value = err.message
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <section class="min-h-[80vh] flex items-center justify-center pt-32 pb-16 px-6 bg-cream">
    <div class="w-full max-w-md bg-white rounded-3xl shadow-sm border border-green-50 p-8">
      <template v-if="!done">
        <h1 class="font-display font-bold text-2xl text-forest mb-2">Daftar sebagai Member</h1>
        <p class="text-gray-500 text-sm mb-6">Gratis. Isi data di bawah untuk membuat akun member.</p>

        <form @submit.prevent="handleSubmit" class="space-y-4">
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">Nama Lengkap</label>
            <input v-model="fullName" type="text" required placeholder="Nama Anda"
              class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition" />
          </div>
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">Nomor HP</label>
            <input v-model="phone" type="tel" required placeholder="Masukan nomor telepon"
              class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition" />
          </div>
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">Email</label>
            <input v-model="email" type="email" required placeholder="Buat alamat email"
              class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition" />
          </div>
          <div>
            <label class="text-sm font-medium text-gray-700 block mb-1">Kata Sandi</label>
            <input v-model="password" type="password" required placeholder="Minimal 6 karakter"
              class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition" />
          </div>

          <p v-if="errorMsg" class="text-red-500 text-sm">{{ errorMsg }}</p>

          <button type="submit" :disabled="submitting"
            class="w-full bg-forest text-white py-3 rounded-xl font-semibold hover:bg-leaf transition-all disabled:opacity-60">
            {{ submitting ? 'Memproses...' : 'Daftar' }}
          </button>
        </form>

        <p class="text-center text-sm text-gray-500 mt-6">
          Sudah jadi member?
          <router-link to="/login" class="text-leaf font-semibold hover:underline">Masuk di sini</router-link>
        </p>
      </template>

      <template v-else>
        <div class="text-center py-8">
          <div class="w-16 h-16 bg-mint rounded-full flex items-center justify-center mx-auto mb-4 text-2xl">✅</div>
          <h4 class="font-display font-bold text-xl text-forest mb-2">Cek Email Kamu</h4>
          <p class="text-gray-500 text-sm">Kami sudah mengirim tautan konfirmasi ke email kamu. Konfirmasi dulu sebelum masuk.</p>
          <router-link to="/login" class="inline-block mt-6 text-leaf font-semibold hover:underline">Ke halaman masuk →</router-link>
        </div>
      </template>
    </div>
  </section>
</template>
