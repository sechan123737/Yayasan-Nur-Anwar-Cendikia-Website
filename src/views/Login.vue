<script setup>
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuth } from '../composables/useAuth'

const email = ref('')
const password = ref('')
const errorMsg = ref('')
const submitting = ref(false)

const router = useRouter()
const route = useRoute()
const { signIn } = useAuth()

async function handleSubmit() {
  errorMsg.value = ''
  submitting.value = true
  try {
    await signIn({ email: email.value, password: password.value })
    router.push(route.query.redirect || '/')
  } catch (err) {
    errorMsg.value = err.message === 'Invalid login credentials'
      ? 'Email atau kata sandi salah.'
      : err.message
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <section class="min-h-[80vh] flex items-center justify-center pt-32 pb-16 px-6 bg-cream">
    <div class="w-full max-w-md bg-white rounded-3xl shadow-sm border border-green-50 p-8">
      <h1 class="font-display font-bold text-2xl text-forest mb-2">Masuk sebagai Member</h1>
      <p class="text-gray-500 text-sm mb-6">Masuk untuk membaca detail lengkap setiap program.</p>

      <form @submit.prevent="handleSubmit" class="space-y-4">
        <div>
          <label class="text-sm font-medium text-gray-700 block mb-1">Email</label>
          <input v-model="email" type="email" required placeholder="Masukan alamat email"
            class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition" />
        </div>
        <div>
          <label class="text-sm font-medium text-gray-700 block mb-1">Kata Sandi</label>
          <input v-model="password" type="password" required placeholder="••••••••"
            class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:border-leaf focus:ring-2 focus:ring-mint outline-none transition" />
        </div>

        <p v-if="errorMsg" class="text-red-500 text-sm">{{ errorMsg }}</p>

        <button type="submit" :disabled="submitting"
          class="w-full bg-forest text-white py-3 rounded-xl font-semibold hover:bg-leaf transition-all disabled:opacity-60">
          {{ submitting ? 'Memproses...' : 'Masuk' }}
        </button>
      </form>

      <p class="text-center text-sm text-gray-500 mt-6">
        Belum jadi member?
        <router-link to="/daftar" class="text-leaf font-semibold hover:underline">Daftar di sini</router-link>
      </p>
    </div>
  </section>
</template>
