defmodule RednewsWeb.UserLoginLive do
  use RednewsWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen dark:bg-gradient-to-br dark:from-gray-900 dark:via-blue-900 dark:to-purple-900 bg-gradient-to-br from-[#6a11cb] via-[#2575fc] to-[#00d4ff] flex items-center justify-center p-6">
      <div class="w-full max-w-7xl grid grid-cols-1 lg:grid-cols-2 bg-white shadow-2xl rounded-3xl overflow-hidden animate-fade-in">
        <div class="hidden lg:block relative overflow-hidden dark:bg-gradient-to-br dark:from-gray-800 dark:via-gray-900 dark:to-indigo-800 bg-gradient-to-br from-[#6a11cb] via-[#2575fc] to-[#00d4ff]">
          <div class="absolute inset-0 bg-pattern opacity-20"></div>
          <div class="relative z-10 flex items-center justify-center h-full p-10 text-white text-center">
            <div class="space-y-6">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 200 200"
                class="mx-auto w-64 h-64 animate-bounce"
              >
                <circle cx="100" cy="100" r="90" fill="rgba(255,255,255,0.1)" />
                <circle cx="100" cy="100" r="70" fill="rgba(255,255,255,0.2)" />
                <path d="M50 100 L100 50 L150 100 L100 150 Z" fill="white" opacity="0.7" />
                <circle cx="100" cy="100" r="30" fill="white" />
              </svg>
              <h2 class="text-3xl font-bold">
                {gettext("Welcome Back!")}
              </h2>
              <p class="text-sm opacity-80">
                {gettext("Your digital adventure continues here")}
              </p>
            </div>
          </div>
        </div>

        <div class="p-10 dark:bg-gray-900 bg-white flex flex-col justify-center space-y-6">
          <div class="text-center mb-8">
            <h1 class="text-3xl font-black bg-clip-text text-transparent bg-gradient-to-r from-[#6a11cb] to-[#2575fc] mb-4">
              {gettext("Always connected with events")}
            </h1>
            <p class="text-sm dark:text-gray-300 text-gray-600">
              {gettext("Read, Share, Discuss")}
            </p>
          </div>

          <.simple_form
            for={@form}
            id="login_form"
            action={~p"/users/log_in"}
            phx-update="ignore"
            class="space-y-5"
          >
            <.input
              field={@form[:email]}
              type="email"
              label={gettext("Email Address")}
              required
              class="focus:ring-2  group text-white focus:ring-[#6a11cb] focus:border-[#6a11cb]
                           transition-all duration-300 ease-in-out
                           group-hover:border-[#2575fc]"
            />

            <.input
              field={@form[:password]}
              type="password"
              label={gettext("Password")}
              required
              class="focus:ring-2 focus:ring-[#2575fc] focus:border-[#2575fc]
                           transition-all duration-300 ease-in-out
                           group-hover:border-[#00d4ff]"
            />

            <div class="flex justify-between items-center">
              <div class="flex items-center">
                <.input
                  field={@form[:remember_me]}
                  type="checkbox"
                  label={gettext("Remember me")}
                  class="text-[#6a11cb] focus:ring-[#6a11cb]"
                />
              </div>

              <.link
                href={~p"/users/reset_password"}
                class="text-sm font-semibold text-[#2575fc] hover:text-[#6a11cb]
                       transition-colors duration-300
                       hover:underline"
              >
                {gettext("Forgot password?")}
              </.link>
            </div>

            <div class="pt-4">
              <.button
                phx-disable-with={gettext("Logging in...")}
                class="w-full py-3 rounded-full text-white font-bold
                       bg-gradient-to-r from-[#6a11cb] to-[#2575fc]
                       hover:from-[#2575fc] hover:to-[#6a11cb]
                       transition-all duration-300
                       transform hover:scale-105
                       focus:outline-none focus:ring-4 focus:ring-[#00d4ff]/50
                       shadow-lg hover:shadow-xl"
              >
                {gettext("Log In")}
              </.button>
            </div>
          </.simple_form>

          <div class="text-center dark:text-gray-200 text-sm text-gray-600 mt-4">
            {gettext("New to our platform?")}
            <.link
              navigate={~p"/users/register"}
              class="ml-2 font-semibold text-[#6a11cb] hover:underline"
            >
              {gettext("Create an Account")}
            </.link>
          </div>

          <div class="relative py-2">
            <div class="absolute inset-0 flex items-center">
              <div class="w-full border-t border-gray-300"></div>
            </div>
            <div class="relative flex justify-center">
              <span class="px-4 dark:bg-gray-900 dark:text-gray-200 bg-white text-sm text-gray-500">
                {gettext("Other entry options")}
              </span>
            </div>
          </div>

          <div class="grid grid-cols-3 gap-4">
            <a
              href="/news"
              class="bg-gray-700 font-bold space-x-2 text-white py-2 rounded-lg hover:opacity-90 transition-opacity flex items-center justify-center"
            >
              <p>{gettext("As Guest")}</p>

              <svg
                fill="#ffffff"
                width="24"
                height="24"
                viewBox="0 0 512 512"
                xmlns="http://www.w3.org/2000/svg"
                stroke="#ffffff"
              >
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                <g id="SVGRepo_iconCarrier">
                  <g id="Hacker_anonymous">
                    <path d="M475.3571,413.24a69.9,69.9,0,0,0-39.8845-57.4407l-39.9287-18.7987,21.5791-44.5621a89.4527,89.4527,0,0,0,.0025-77.9684L359.7988,96.0682C317.7933,9.3105,194.2088,9.31,152.2019,96.0666L94.87,214.4745a89.445,89.445,0,0,0,.0049,77.9692l21.581,44.5569L76.5256,355.8a69.898,69.898,0,0,0-39.8831,57.439l-3.612,43.3773a22.5157,22.5157,0,0,0,22.4381,24.3842H456.5337A22.5134,22.5134,0,0,0,478.97,456.6187ZM364,260.1205a107.9746,107.9746,0,0,1-98.1035,107.5V341.1249a9.8965,9.8965,0,0,0-19.793,0v26.4957A107.9746,107.9746,0,0,1,148,260.1205V203.44a28.8192,28.8192,0,0,1,28.8193-28.8193H335.1806A28.8193,28.8193,0,0,1,364,203.44Z">
                    </path>

                    <path d="M321.8213,275.9979a9.91,9.91,0,0,0-12.3135,6.6709,13.5776,13.5776,0,0,1-26.0156,0,9.9026,9.9026,0,1,0-18.9844,5.6426,33.3877,33.3877,0,0,0,63.9844,0A9.9125,9.9125,0,0,0,321.8213,275.9979Z">
                    </path>

                    <path d="M240.8213,275.9979a9.8908,9.8908,0,0,0-12.3135,6.6709,13.5776,13.5776,0,0,1-26.0156,0,9.9026,9.9026,0,1,0-18.9844,5.6426,33.3877,33.3877,0,0,0,63.9844,0A9.9125,9.9125,0,0,0,240.8213,275.9979Z">
                    </path>

                    <path d="M319,227.4384H283a9.8965,9.8965,0,1,0,0,19.7929h36a9.8965,9.8965,0,1,0,0-19.7929Z">
                    </path>

                    <path d="M193,247.2313h36a9.8965,9.8965,0,1,0,0-19.7929H193a9.8965,9.8965,0,1,0,0,19.7929Z">
                    </path>
                  </g>
                </g>
              </svg>
            </a>
            <button class="bg-gray-800/80 space-x-2 font-bold text-white py-2 rounded-lg hover:opacity-90 transition-opacity flex items-center justify-center">
              <p>Google</p>
              <svg
                viewBox="-0.5 0 48 48"
                version="1.1"
                width="24"
                height="24"
                xmlns="http://www.w3.org/2000/svg"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                fill="#000000"
              >
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                <g id="SVGRepo_iconCarrier">
                  <defs></defs>

                  <g id="Icons" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
                    <g id="Color-" transform="translate(-401.000000, -860.000000)">
                      <g id="Google" transform="translate(401.000000, 860.000000)">
                        <path
                          d="M9.82727273,24 C9.82727273,22.4757333 10.0804318,21.0144 10.5322727,19.6437333 L2.62345455,13.6042667 C1.08206818,16.7338667 0.213636364,20.2602667 0.213636364,24 C0.213636364,27.7365333 1.081,31.2608 2.62025,34.3882667 L10.5247955,28.3370667 C10.0772273,26.9728 9.82727273,25.5168 9.82727273,24"
                          id="Fill-1"
                          fill="#FBBC05"
                        >
                        </path>

                        <path
                          d="M23.7136364,10.1333333 C27.025,10.1333333 30.0159091,11.3066667 32.3659091,13.2266667 L39.2022727,6.4 C35.0363636,2.77333333 29.6954545,0.533333333 23.7136364,0.533333333 C14.4268636,0.533333333 6.44540909,5.84426667 2.62345455,13.6042667 L10.5322727,19.6437333 C12.3545909,14.112 17.5491591,10.1333333 23.7136364,10.1333333"
                          id="Fill-2"
                          fill="#EB4335"
                        >
                        </path>

                        <path
                          d="M23.7136364,37.8666667 C17.5491591,37.8666667 12.3545909,33.888 10.5322727,28.3562667 L2.62345455,34.3946667 C6.44540909,42.1557333 14.4268636,47.4666667 23.7136364,47.4666667 C29.4455,47.4666667 34.9177955,45.4314667 39.0249545,41.6181333 L31.5177727,35.8144 C29.3995682,37.1488 26.7323182,37.8666667 23.7136364,37.8666667"
                          id="Fill-3"
                          fill="#34A853"
                        >
                        </path>

                        <path
                          d="M46.1454545,24 C46.1454545,22.6133333 45.9318182,21.12 45.6113636,19.7333333 L23.7136364,19.7333333 L23.7136364,28.8 L36.3181818,28.8 C35.6879545,31.8912 33.9724545,34.2677333 31.5177727,35.8144 L39.0249545,41.6181333 C43.3393409,37.6138667 46.1454545,31.6490667 46.1454545,24"
                          id="Fill-4"
                          fill="#4285F4"
                        >
                        </path>
                      </g>
                    </g>
                  </g>
                </g>
              </svg>
            </button>
            <button class="bg-sky-500 space-x-2 font-bold text-white py-2 rounded-lg hover:opacity-90 transition-opacity flex items-center justify-center">
              <p>ВКонтакте</p>

              <svg
                width="24"
                height="24"
                viewBox="0 0 1024 1024"
                xmlns="http://www.w3.org/2000/svg"
                fill="#000000"
              >
                <g id="SVGRepo_bgCarrier" stroke-width="0"></g>
                <g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g>
                <g id="SVGRepo_iconCarrier">
                  <circle cx="512" cy="512" r="512" style="fill:#2787f5"></circle>

                  <path
                    d="M585.83 271.5H438.17c-134.76 0-166.67 31.91-166.67 166.67v147.66c0 134.76 31.91 166.67 166.67 166.67h147.66c134.76 0 166.67-31.91 166.67-166.67V438.17c0-134.76-32.25-166.67-166.67-166.67zm74 343.18h-35c-13.24 0-17.31-10.52-41.07-34.62-20.71-20-29.87-22.74-35-22.74-7.13 0-9.17 2-9.17 11.88v31.57c0 8.49-2.72 13.58-25.12 13.58-37 0-78.07-22.4-106.93-64.16-43.45-61.1-55.33-106.93-55.33-116.43 0-5.09 2-9.84 11.88-9.84h35c8.83 0 12.22 4.07 15.61 13.58 17.31 49.9 46.17 93.69 58 93.69 4.41 0 6.45-2 6.45-13.24v-51.6c-1.36-23.76-13.92-25.8-13.92-34.28 0-4.07 3.39-8.15 8.83-8.15h55c7.47 0 10.18 4.07 10.18 12.9v69.58c0 7.47 3.39 10.18 5.43 10.18 4.41 0 8.15-2.72 16.29-10.86 25.12-28.17 43.11-71.62 43.11-71.62 2.38-5.09 6.45-9.84 15.28-9.84h35c10.52 0 12.9 5.43 10.52 12.9-4.41 20.37-47.18 80.79-47.18 80.79-3.73 6.11-5.09 8.83 0 15.61 3.73 5.09 16 15.61 24.1 25.12 14.94 17 26.48 31.23 29.53 41.07 3.45 9.84-1.65 14.93-11.49 14.93z"
                    style="fill:#fff"
                  >
                  </path>
                </g>
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>

    <style>
      .bg-pattern {
        background-image:
          linear-gradient(45deg, rgba(255,255,255,0.1) 25%, transparent 25%),
          linear-gradient(-45deg, rgba(255,255,255,0.1) 25%, transparent 25%);
        background-size: 40px 40px;
      }

      @keyframes fade-in {
        from { opacity: 0; transform: scale(0.9); }
        to { opacity: 1; transform: scale(1); }
      }

      .animate-fade-in {
        animation: fade-in 0.5s ease-out;
      }
    </style>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
