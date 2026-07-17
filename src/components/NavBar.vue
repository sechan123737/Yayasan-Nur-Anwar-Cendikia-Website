<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuth } from '../composables/useAuth'

const mobileOpen = ref(false)
const router = useRouter()
const { isLoggedIn, isAdmin, profile, signOut } = useAuth()

async function handleLogout() {
  await signOut()
  mobileOpen.value = false
  router.push('/')
}
</script>

<template>
  <nav class="fixed top-0 left-0 right-0 z-50 bg-white/90 backdrop-blur-md border-b border-green-100">
    <div class="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
      <router-link to="/" class="flex items-center gap-3">
        <img src="/images/Logo.png" alt="Logo Yayasan Nur Anwar Cendikia" class="w-10 h-10 rounded-full object-cover" />
        <div>
          <span class="font-display font-bold text-forest text-lg leading-tight block">Nur Anwar Cendikia</span>
          <span class="text-xs text-leaf font-medium tracking-wider uppercase">Foundation</span>
        </div>
      </router-link>

      <div class="hidden md:flex items-center gap-8 text-sm font-medium text-gray-600">
        <router-link to="/#about" class="hover:text-forest transition-colors">Tentang</router-link>
        <router-link to="/#impact" class="hover:text-forest transition-colors">Dampak</router-link>
        <router-link to="/#programs" class="hover:text-forest transition-colors">Program</router-link>
        <router-link to="/berita" class="hover:text-forest transition-colors">Berita</router-link>
        <router-link to="/#donate" class="hover:text-forest transition-colors">Donasi</router-link>

        <router-link v-if="isAdmin" to="/admin" class="hover:text-forest transition-colors">Panel Admin</router-link>

        <template v-if="!isLoggedIn">
          <router-link to="/login" class="hover:text-forest transition-colors">Masuk</router-link>
          <router-link to="/daftar" class="bg-forest text-white px-5 py-2.5 rounded-full hover:bg-leaf transition-colors">Jadi Member</router-link>
        </template>
        <template v-else>
          <span class="text-gray-400">Halo, {{ profile?.full_name?.split(' ')[0] || 'Member' }}</span>
          <button @click="handleLogout" class="bg-gray-100 text-gray-600 px-5 py-2.5 rounded-full hover:bg-gray-200 transition-colors">Keluar</button>
        </template>
      </div>

      <button class="md:hidden text-forest" @click="mobileOpen = !mobileOpen">
        <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="4" y1="6" x2="20" y2="6"/><line x1="4" y1="12" x2="20" y2="12"/><line x1="4" y1="18" x2="20" y2="18"/></svg>
      </button>
    </div>

    <div v-if="mobileOpen" class="md:hidden px-6 pb-4 space-y-3">
      <router-link to="/#about" class="block text-gray-600 hover:text-forest py-1" @click="mobileOpen = false">Tentang</router-link>
      <router-link to="/#impact" class="block text-gray-600 hover:text-forest py-1" @click="mobileOpen = false">Dampak</router-link>
      <router-link to="/#programs" class="block text-gray-600 hover:text-forest py-1" @click="mobileOpen = false">Program</router-link>
      <router-link to="/berita" class="block text-gray-600 hover:text-forest py-1" @click="mobileOpen = false">Berita</router-link>
      <router-link to="/#donate" class="block text-gray-600 hover:text-forest py-1" @click="mobileOpen = false">Donasi</router-link>
      <router-link v-if="isAdmin" to="/admin" class="block text-gray-600 hover:text-forest py-1" @click="mobileOpen = false">Panel Admin</router-link>

      <template v-if="!isLoggedIn">
        <router-link to="/login" class="block text-gray-600 hover:text-forest py-1" @click="mobileOpen = false">Masuk</router-link>
        <router-link to="/daftar" class="block bg-forest text-white px-5 py-2.5 rounded-full text-center" @click="mobileOpen = false">Jadi Member</router-link>
      </template>
      <button v-else @click="handleLogout" class="block w-full bg-gray-100 text-gray-600 px-5 py-2.5 rounded-full text-center">Keluar</button>
    </div>
  </nav>
</template>