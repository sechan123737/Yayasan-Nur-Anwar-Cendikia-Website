<script setup>
const year = new Date().getFullYear()
</script>

<template>
  <footer class="bg-forest text-white py-16">
    <div class="max-w-7xl mx-auto px-6">
      <div class="grid md:grid-cols-4 gap-10 mb-12">
        <div class="md:col-span-2">
          <div class="flex items-center gap-3 mb-4">
              <img src="/images/Logo.png" alt="Logo Yayasan Nur Anwar Cendikia" class="w-10 h-10 rounded-full object-cover" />
            <span class="font-display font-bold text-xl">Nur Anwar Cendikia</span>
          </div>
          <p class="text-white/60 text-sm leading-relaxed max-w-sm">
            Yayasan Nur Anwar Cendikia adalah yayasan nirlaba terdaftar yang berdedikasi untuk pendidikan dan kesejahteraan sosial di seluruh Indonesia.
          </p>
        </div>
        <div>
          <h4 class="font-semibold mb-4 text-white/90">Tautan Cepat</h4>
          <ul class="space-y-2 text-sm text-white/60">
            <li><router-link to="/#about" class="hover:text-white transition-colors">Tentang Kami</router-link></li>
            <li><router-link to="/#programs" class="hover:text-white transition-colors">Program</router-link></li>
            <li><router-link to="/#donate" class="hover:text-white transition-colors">Donasi</router-link></li>
            <li><router-link to="/daftar" class="hover:text-white transition-colors">Jadi Member</router-link></li>
          </ul>
        </div>
        <div>
          <h4 class="font-semibold mb-4 text-white/90">Hubungi Kami</h4>
          <ul class="space-y-2 text-sm text-white/60">
            <li class="flex items-center gap-2">info@nuranwar.org</li>
            <li class="flex items-center gap-2">+62 21 555 0123</li>
            <li class="flex items-center gap-2">Jakarta, Indonesia</li>
          </ul>
        </div>
      </div>
      <div class="border-t border-white/10 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
        <p class="text-white/40 text-sm">© {{ year }} Yayasan Nur Anwar Cendikia. Semua hak dilindungi.</p>
        <div class="flex gap-4">
          <a href="#" class="w-9 h-9 bg-white/10 rounded-full flex items-center justify-center hover:bg-white/20 transition-colors">IG</a>
          <a href="#" class="w-9 h-9 bg-white/10 rounded-full flex items-center justify-center hover:bg-white/20 transition-colors">FB</a>
          <a href="#" class="w-9 h-9 bg-white/10 rounded-full flex items-center justify-center hover:bg-white/20 transition-colors">TW</a>
        </div>
      </div>
    </div>
  </footer>
</template>
