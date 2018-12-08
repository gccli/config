(defun newpython ()
  "Insert a template for an empty Python script"
  (interactive)
  (insert "#!/usr/bin/env python\n"
          "# -*- coding: utf-8 -*-\n"
          "\n"
          "\n"
          "if __name__ == '__main__':\n"
          "\n"
          )
  (forward-line -4)
  )

(defun newshell ()
  (interactive)
  (insert "#!/bin/bash\n"
          "\n"
          "\n"
          )
  )

(add-hook 'python-mode-hook
          (lambda ()
            (if (= (buffer-size) 0)
                (newpython))
            (not-modified)
            ))


(add-hook 'sh-mode-hook
          (lambda ()
            (if (= (buffer-size) 0)
                (newshell))
            (not-modified)
            ))

(provide 'setup-autoinsert)
